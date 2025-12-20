from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from ..models.activity import Activity
from ..models.baby import Baby
from typing import Dict, List, Any
from .ml_service import MLService


class InsightsService:
    def __init__(self, db: Session):
        self.db = db
    
    def generate_insights(self, baby_id: int, days: int = 14) -> Dict[str, Any]:
        """Generate insights and recommendations for a baby"""
        end_date = datetime.now(timezone.utc)
        start_date = end_date - timedelta(days=days)
        
        # Get all activities in period
        activities = self.db.query(Activity).filter(
            Activity.baby_id == baby_id,
            Activity.timestamp >= start_date,
            Activity.timestamp <= end_date
        ).all()
        
        if not activities:
            return {
                "insights": [],
                "alerts": [],
                "patterns": {},
                "recommendations": [],
                "ml_insights": []
            }
        
        # Generate different types of insights
        insights = []
        alerts = []
        patterns = self._detect_patterns(activities, days)
        recommendations = self._generate_recommendations(activities, patterns)
        
        # Generate ML insights
        ml_insights = self._generate_ml_insights(activities)
        
        # Analyze feeding
        feeding_insights = self._analyze_feeding(activities, days)
        insights.extend(feeding_insights.get("insights", []))
        alerts.extend(feeding_insights.get("alerts", []))
        
        # Analyze sleep
        sleep_insights = self._analyze_sleep(activities, days)
        insights.extend(sleep_insights.get("insights", []))
        alerts.extend(sleep_insights.get("alerts", []))
        
        # Analyze diaper changes
        diaper_insights = self._analyze_diapers(activities, days)
        insights.extend(diaper_insights.get("insights", []))
        
        return {
            "insights": insights,
            "alerts": alerts,
            "patterns": patterns,
            "recommendations": recommendations,
            "ml_insights": ml_insights
        }
    
    def _detect_patterns(self, activities: List[Activity], days: int) -> Dict[str, Any]:
        """Detect patterns in activities"""
        patterns = {}
        
        # Pattern: Best sleep time
        sleep_activities = [a for a in activities if a.type == 'sleep']
        if sleep_activities:
            # Group by hour
            hours_count = {}
            for activity in sleep_activities:
                hour = activity.timestamp.hour
                duration = activity.data.get('duration_hours', 0) if activity.data else 0
                if hour not in hours_count:
                    hours_count[hour] = []
                hours_count[hour].append(duration)
            
            # Find hour with longest average sleep
            if hours_count:
                best_hour = max(hours_count.items(), key=lambda x: sum(x[1]) / len(x[1]))
                patterns['best_sleep_hour'] = {
                    'hour': best_hour[0],
                    'avg_duration': sum(best_hour[1]) / len(best_hour[1])
                }
        
        # Pattern: Feeding frequency
        feeding_activities = [a for a in activities if a.type == 'feeding']
        if len(feeding_activities) > 1:
            # Calculate average time between feedings
            feeding_activities.sort(key=lambda x: x.timestamp)
            intervals = []
            for i in range(1, len(feeding_activities)):
                diff = (feeding_activities[i].timestamp - feeding_activities[i-1].timestamp).total_seconds() / 3600
                intervals.append(diff)
            
            if intervals:
                patterns['avg_feeding_interval'] = sum(intervals) / len(intervals)
        
        return patterns
    
    def _analyze_feeding(self, activities: List[Activity], days: int) -> Dict[str, Any]:
        """Analyze feeding patterns"""
        insights = []
        alerts = []
        
        feeding_activities = [a for a in activities if a.type == 'feeding']
        
        if not feeding_activities:
            alerts.append({
                "type": "warning",
                "title": "Sin registros de alimentación",
                "message": "No hay registros de alimentación en los últimos días",
                "icon": "warning"
            })
            return {"insights": insights, "alerts": alerts}
        
        # Calculate daily average
        daily_avg = len(feeding_activities) / days
        
        # Calculate total quantity
        total_ml = sum([
            a.data.get('quantity_ml', 0) 
            for a in feeding_activities 
            if a.data and a.data.get('quantity_ml')
        ])
        
        if total_ml > 0:
            avg_ml_per_day = total_ml / days
            insights.append({
                "type": "info",
                "title": "Alimentación diaria",
                "message": f"Promedio de {daily_avg:.1f} tomas/día ({avg_ml_per_day:.0f} ml/día)",
                "icon": "restaurant"
            })
        
        # Check last feeding
        last_feeding = max(feeding_activities, key=lambda x: x.timestamp)
        hours_since = (datetime.now(timezone.utc) - last_feeding.timestamp).total_seconds() / 3600
        
        if hours_since > 4:
            alerts.append({
                "type": "alert",
                "title": "Tiempo desde última toma",
                "message": f"Han pasado {hours_since:.1f} horas desde la última toma",
                "icon": "alarm"
            })
        
        # Compare with previous period
        mid_point = datetime.now(timezone.utc) - timedelta(days=days/2)
        recent_feedings = [a for a in feeding_activities if a.timestamp >= mid_point]
        old_feedings = [a for a in feeding_activities if a.timestamp < mid_point]
        
        if old_feedings and recent_feedings:
            recent_avg = len(recent_feedings) / (days/2)
            old_avg = len(old_feedings) / (days/2)
            change = ((recent_avg - old_avg) / old_avg) * 100
            
            if abs(change) > 20:
                direction = "aumentado" if change > 0 else "disminuido"
                insights.append({
                    "type": "trend",
                    "title": "Cambio en alimentación",
                    "message": f"La frecuencia de alimentación ha {direction} un {abs(change):.0f}% en la última semana",
                    "icon": "trending_up" if change > 0 else "trending_down"
                })
        
        return {"insights": insights, "alerts": alerts}
    
    def _analyze_sleep(self, activities: List[Activity], days: int) -> Dict[str, Any]:
        """Analyze sleep patterns"""
        insights = []
        alerts = []
        
        sleep_activities = [a for a in activities if a.type == 'sleep']
        
        if not sleep_activities:
            return {"insights": insights, "alerts": alerts}
        
        # Calculate total sleep hours
        total_hours = sum([
            a.data.get('duration_hours', 0) 
            for a in sleep_activities 
            if a.data
        ])
        
        avg_hours_per_day = total_hours / days
        
        insights.append({
            "type": "info",
            "title": "Sueño diario",
            "message": f"Promedio de {avg_hours_per_day:.1f} horas de sueño al día",
            "icon": "bedtime"
        })
        
        # Check if sleep is adequate (babies 0-3 months: 14-17h, 4-11 months: 12-15h)
        if avg_hours_per_day < 10:
            alerts.append({
                "type": "warning",
                "title": "Poco sueño",
                "message": f"El bebé está durmiendo menos de lo recomendado ({avg_hours_per_day:.1f}h/día)",
                "icon": "warning"
            })
        
        return {"insights": insights, "alerts": alerts}
    
    def _analyze_diapers(self, activities: List[Activity], days: int) -> Dict[str, Any]:
        """Analyze diaper change patterns"""
        insights = []
        
        diaper_activities = [a for a in activities if a.type == 'diaper']
        
        if not diaper_activities:
            return {"insights": insights}
        
        daily_avg = len(diaper_activities) / days
        
        insights.append({
            "type": "info",
            "title": "Cambios de pañal",
            "message": f"Promedio de {daily_avg:.1f} cambios al día",
            "icon": "baby_changing_station"
        })
        
        # Analyze types
        wet_count = len([a for a in diaper_activities if a.data and a.data.get('type') == 'wet'])
        dirty_count = len([a for a in diaper_activities if a.data and a.data.get('type') == 'dirty'])
        
        if wet_count > 0 or dirty_count > 0:
            insights.append({
                "type": "info",
                "title": "Distribución de pañales",
                "message": f"{wet_count} mojados, {dirty_count} sucios",
                "icon": "info"
            })
        
        return {"insights": insights}
    
    def _generate_ml_insights(self, activities: List[Activity]) -> List[Dict[str, Any]]:
        """Generate ML-powered insights"""
        ml_insights = []
        
        # 1. ML Prediction: Next feeding
        feeding_pred = MLService.predict_next_feeding(activities)
        if feeding_pred.get("has_prediction"):
            if feeding_pred.get("is_overdue"):
                ml_insights.append({
                    "type": "ml_alert",
                    "title": "🤖 Predicción ML: Próxima toma",
                    "message": f"El bebé podría necesitar comer pronto. Han pasado {feeding_pred['hours_since_last']:.1f}h desde la última toma (promedio: {feeding_pred['avg_interval_hours']:.1f}h)",
                    "icon": "smart_toy",
                    "ml_data": feeding_pred
                })
            else:
                hours = feeding_pred['hours_until_next']
                if hours > 0:
                    ml_insights.append({
                        "type": "ml_info",
                        "title": "🤖 Predicción ML: Próxima toma",
                        "message": f"Próxima toma estimada en {hours:.1f} horas (confianza: {feeding_pred['confidence']:.0f}%)",
                        "icon": "smart_toy",
                        "ml_data": feeding_pred
                    })
        
        # 2. ML Detection: Feeding anomalies
        anomalies = MLService.detect_feeding_anomalies(activities)
        if anomalies.get("has_analysis") and anomalies.get("anomalies_detected", 0) > 0:
            ml_insights.append({
                "type": "ml_warning",
                "title": "🤖 ML detectó patrones inusuales",
                "message": f"Se detectaron {anomalies['anomalies_detected']} alimentaciones con patrones atípicos ({anomalies['anomaly_rate']:.1f}% del total)",
                "icon": "warning",
                "ml_data": anomalies
            })
        
        # 3. ML Classification: Sleep quality
        sleep_quality = MLService.classify_sleep_quality(activities)
        if sleep_quality.get("has_classification"):
            ml_insights.append({
                "type": "ml_classification",
                "title": f"🤖 Calidad de sueño: {sleep_quality['quality']}",
                "message": f"Promedio de {sleep_quality['sleep_per_day_hours']:.1f}h/día. {sleep_quality['recommendation']}",
                "icon": "bedtime",
                "ml_data": sleep_quality
            })
        
        # 4. ML Prediction: Sleep duration
        sleep_pred = MLService.predict_sleep_duration(activities)
        if sleep_pred.get("has_prediction"):
            ml_insights.append({
                "type": "ml_prediction",
                "title": "🤖 Predicción ML: Duración de sueño",
                "message": f"Si duerme ahora (hora {sleep_pred['current_hour']}:00), durará aproximadamente {sleep_pred['predicted_duration_hours']:.1f} horas",
                "icon": "bedtime",
                "ml_data": sleep_pred
            })
        
        # 5. NEW: ML Prediction: Optimal feeding amount (Random Forest)
        optimal_feeding = MLService.predict_optimal_feeding_amount(activities)
        if optimal_feeding.get("has_prediction"):
            ml_insights.append({
                "type": "ml_prediction",
                "title": "🤖 Random Forest: Cantidad óptima",
                "message": f"Para esta toma, se recomiendan {optimal_feeding['predicted_amount_ml']:.0f}ml (promedio histórico: {optimal_feeding['avg_amount_ml']:.0f}ml)",
                "icon": "restaurant",
                "ml_data": optimal_feeding
            })
        
        # 6. NEW: ML Clustering: Routine patterns (K-Means)
        routines = MLService.identify_routine_clusters(activities)
        if routines.get("has_analysis"):
            current_type = routines.get("current_pattern_type", "Desconocido")
            ml_insights.append({
                "type": "ml_classification",
                "title": "🤖 K-Means: Patrón del día actual",
                "message": f"Hoy sigue un patrón de '{current_type}' (identificados {len(routines['clusters'])} patrones diferentes)",
                "icon": "pattern",
                "ml_data": routines
            })
        
        # 7. NEW: ML Correlation: Feeding-Sleep analysis
        correlation = MLService.analyze_feeding_sleep_correlation(activities)
        if correlation.get("has_analysis") and correlation.get("insights"):
            insights_text = " | ".join(correlation['insights'][:2])
            ml_insights.append({
                "type": "ml_info",
                "title": "🤖 Análisis de correlación",
                "message": insights_text,
                "icon": "analytics",
                "ml_data": correlation
            })
        
        # 8. NEW: ML Prediction: Next diaper change (Logistic Regression)
        diaper_pred = MLService.predict_diaper_change(activities)
        if diaper_pred.get("has_prediction"):
            if diaper_pred.get("is_overdue"):
                ml_insights.append({
                    "type": "ml_alert",
                    "title": "🤖 Predicción: Cambio de pañal",
                    "message": f"Cambio recomendado pronto (han pasado {diaper_pred['hours_since_last']:.1f}h, promedio: {diaper_pred['avg_interval_hours']:.1f}h)",
                    "icon": "baby_changing_station",
                    "ml_data": diaper_pred
                })
            elif diaper_pred['minutes_until_next'] <= 60:
                ml_insights.append({
                    "type": "ml_info",
                    "title": "🤖 Predicción: Cambio de pañal",
                    "message": f"Próximo cambio estimado en {diaper_pred['minutes_until_next']:.0f} minutos (probabilidad: {diaper_pred['probability']:.0f}%)",
                    "icon": "baby_changing_station",
                    "ml_data": diaper_pred
                })
        
        # 9. NEW: Time Series Forecast: Next week patterns
        forecast = MLService.forecast_next_week(activities)
        if forecast.get("has_forecast"):
            fc = forecast['next_week_forecast']
            ml_insights.append({
                "type": "ml_prediction",
                "title": "🤖 Forecast: Próxima semana",
                "message": f"Predicción: {fc['feeding_per_day']:.1f} tomas/día, {fc['sleep_hours_per_day']:.1f}h sueño/día, {fc['diaper_per_day']:.1f} pañales/día",
                "icon": "trending_up",
                "ml_data": forecast
            })
        
        return ml_insights
    
    def _generate_recommendations(self, activities: List[Activity], patterns: Dict[str, Any]) -> List[Dict[str, str]]:
        """Generate personalized recommendations"""
        recommendations = []
        
        # Recommendation based on best sleep hour
        if 'best_sleep_hour' in patterns:
            hour = patterns['best_sleep_hour']['hour']
            recommendations.append({
                "title": "Mejor horario para dormir",
                "message": f"Tu bebé suele dormir mejor alrededor de las {hour:02d}:00. Intenta establecer una rutina a esa hora.",
                "icon": "lightbulb"
            })
        
        # Recommendation based on feeding interval
        if 'avg_feeding_interval' in patterns:
            interval = patterns['avg_feeding_interval']
            recommendations.append({
                "title": "Patrón de alimentación",
                "message": f"Tu bebé suele comer cada {interval:.1f} horas. Puedes anticipar la próxima toma.",
                "icon": "schedule"
            })
        
        # General recommendations
        sleep_activities = [a for a in activities if a.type == 'sleep']
        if len(sleep_activities) > 0:
            recommendations.append({
                "title": "Consejo de rutina",
                "message": "Mantener horarios consistentes ayuda a establecer mejores patrones de sueño y alimentación.",
                "icon": "auto_awesome"
            })
        
        return recommendations