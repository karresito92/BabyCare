import numpy as np
import pandas as pd
from datetime import datetime, timedelta, timezone
from typing import List, Dict, Any, Tuple
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.ensemble import IsolationForest, RandomForestRegressor
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from scipy.stats import pearsonr
from ..models.activity import Activity


def clean_numpy(data):
    """Recursively convert numpy types to Python types"""
    if isinstance(data, dict):
        return {k: clean_numpy(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [clean_numpy(item) for item in data]
    elif isinstance(data, np.integer):
        return int(data)
    elif isinstance(data, np.floating):
        return float(data)
    elif isinstance(data, np.bool_):
        return bool(data)
    elif isinstance(data, np.ndarray):
        return data.tolist()
    return data


class MLService:
    """Machine Learning service for baby care predictions"""
    
    @staticmethod
    def predict_next_feeding(activities: List[Activity]) -> Dict[str, Any]:
        """Predict when the next feeding will occur"""
        feeding_activities = [a for a in activities if a.type == 'feeding']
        
        if len(feeding_activities) < 3:
            return {
                "has_prediction": False,
                "message": "Necesitas al menos 3 registros de alimentación para predicciones"
            }
        
        feeding_activities.sort(key=lambda x: x.timestamp)
        
        intervals = []
        for i in range(1, len(feeding_activities)):
            diff = (feeding_activities[i].timestamp - feeding_activities[i-1].timestamp).total_seconds() / 3600
            intervals.append(diff)
        
        if not intervals:
            return {"has_prediction": False}
        
        avg_interval = np.mean(intervals)
        std_interval = np.std(intervals) if len(intervals) > 1 else 0
        
        last_feeding = feeding_activities[-1].timestamp
        hours_since = (datetime.now(timezone.utc) - last_feeding).total_seconds() / 3600
        
        predicted_next = last_feeding + timedelta(hours=avg_interval)
        hours_until = (predicted_next - datetime.now(timezone.utc)).total_seconds() / 3600
        
        confidence = max(0, min(100, 100 - (std_interval * 10)))
        
        result = {
            "has_prediction": True,
            "avg_interval_hours": round(avg_interval, 1),
            "std_interval_hours": round(std_interval, 1),
            "hours_since_last": round(hours_since, 1),
            "hours_until_next": round(hours_until, 1),
            "predicted_time": predicted_next.isoformat(),
            "confidence": round(confidence, 0),
            "is_overdue": hours_since > avg_interval + std_interval
        }
        return clean_numpy(result)
    
    @staticmethod
    def detect_feeding_anomalies(activities: List[Activity]) -> Dict[str, Any]:
        """Detect unusual feeding patterns using Isolation Forest"""
        feeding_activities = [a for a in activities if a.type == 'feeding']
        
        if len(feeding_activities) < 10:
            return {
                "has_analysis": False,
                "message": "Necesitas al menos 10 registros para detección de anomalías"
            }
        
        features = []
        for activity in feeding_activities:
            hour = activity.timestamp.hour
            quantity = activity.data.get('quantity_ml', 150) if activity.data else 150
            features.append([hour, quantity])
        
        X = np.array(features)
        
        clf = IsolationForest(contamination=0.1, random_state=42)
        predictions = clf.fit_predict(X)
        
        anomalies = []
        for i, pred in enumerate(predictions):
            if pred == -1:
                activity = feeding_activities[i]
                anomalies.append({
                    "timestamp": activity.timestamp.isoformat(),
                    "hour": activity.timestamp.hour,
                    "quantity_ml": activity.data.get('quantity_ml') if activity.data else None,
                    "reason": "Patrón inusual detectado por ML"
                })
        
        result = {
            "has_analysis": True,
            "total_feedings": len(feeding_activities),
            "anomalies_detected": len(anomalies),
            "anomaly_rate": round(len(anomalies) / len(feeding_activities) * 100, 1),
            "anomalies": anomalies[:5]
        }
        return clean_numpy(result)
    
    @staticmethod
    def classify_sleep_quality(activities: List[Activity]) -> Dict[str, Any]:
        """Classify sleep quality based on duration and frequency"""
        sleep_activities = [a for a in activities if a.type == 'sleep']
        
        if len(sleep_activities) < 5:
            return {
                "has_classification": False,
                "message": "Necesitas al menos 5 registros de sueño"
            }
        
        durations = [
            a.data.get('duration_hours', 0) 
            for a in sleep_activities 
            if a.data
        ]
        
        if not durations:
            return {"has_classification": False}
        
        avg_duration = np.mean(durations)
        total_sleep = sum(durations)
        days = max(1, (max([a.timestamp for a in sleep_activities]) - 
                       min([a.timestamp for a in sleep_activities])).days + 1)
        sleep_per_day = total_sleep / days
        
        if sleep_per_day >= 12 and avg_duration >= 2:
            quality = "Excelente"
            score = 95
            color = "green"
        elif sleep_per_day >= 10 and avg_duration >= 1.5:
            quality = "Buena"
            score = 80
            color = "lightgreen"
        elif sleep_per_day >= 8:
            quality = "Regular"
            score = 60
            color = "orange"
        else:
            quality = "Necesita mejora"
            score = 40
            color = "red"
        
        result = {
            "has_classification": True,
            "quality": quality,
            "score": score,
            "color": color,
            "avg_duration_hours": round(avg_duration, 1),
            "sleep_per_day_hours": round(sleep_per_day, 1),
            "total_sleep_sessions": len(sleep_activities),
            "recommendation": MLService._get_sleep_recommendation(quality)
        }
        return clean_numpy(result)
    
    @staticmethod
    def predict_sleep_duration(activities: List[Activity]) -> Dict[str, Any]:
        """Predict sleep duration based on time of day using Linear Regression"""
        sleep_activities = [a for a in activities if a.type == 'sleep']
        
        if len(sleep_activities) < 5:
            return {
                "has_prediction": False,
                "message": "Necesitas al menos 5 registros de sueño"
            }
        
        X = []
        y = []
        for activity in sleep_activities:
            if activity.data and 'duration_hours' in activity.data:
                hour = activity.timestamp.hour
                duration = activity.data['duration_hours']
                X.append([hour])
                y.append(duration)
        
        if len(X) < 5:
            return {"has_prediction": False}
        
        X = np.array(X)
        y = np.array(y)
        
        model = LinearRegression()
        model.fit(X, y)
        
        current_hour = datetime.now(timezone.utc).hour
        predicted_duration = model.predict([[current_hour]])[0]
        
        r2_score = model.score(X, y)
        confidence = max(0, min(100, r2_score * 100))
        
        result = {
            "has_prediction": True,
            "current_hour": current_hour,
            "predicted_duration_hours": round(max(0, predicted_duration), 1),
            "confidence": round(confidence, 0),
            "model_accuracy": round(r2_score, 2)
        }
        return clean_numpy(result)
    
    @staticmethod
    def predict_optimal_feeding_amount(activities: List[Activity]) -> Dict[str, Any]:
        """Predict optimal feeding amount using Random Forest"""
        feeding_activities = [a for a in activities if a.type == 'feeding']
        
        if len(feeding_activities) < 10:
            return {
                "has_prediction": False,
                "message": "Necesitas al menos 10 registros de alimentación"
            }
        
        X = []
        y = []
        for i, activity in enumerate(feeding_activities):
            if not activity.data or 'quantity_ml' not in activity.data:
                continue
            
            hour = activity.timestamp.hour
            day_of_week = activity.timestamp.weekday()
            
            if i > 0:
                hours_since_last = (activity.timestamp - feeding_activities[i-1].timestamp).total_seconds() / 3600
            else:
                hours_since_last = 3.0
            
            X.append([hour, day_of_week, hours_since_last])
            y.append(activity.data['quantity_ml'])
        
        if len(X) < 10:
            return {"has_prediction": False}
        
        X = np.array(X)
        y = np.array(y)
        
        model = RandomForestRegressor(n_estimators=50, random_state=42, max_depth=5)
        model.fit(X, y)
        
        current_hour = datetime.now(timezone.utc).hour
        current_day = datetime.now(timezone.utc).weekday()
        
        if feeding_activities:
            last_feeding = max(feeding_activities, key=lambda x: x.timestamp)
            hours_since = (datetime.now(timezone.utc) - last_feeding.timestamp).total_seconds() / 3600
        else:
            hours_since = 3.0
        
        predicted_amount = model.predict([[current_hour, current_day, hours_since]])[0]
        
        score = model.score(X, y)
        confidence = max(0, min(100, score * 100))
        
        result = {
            "has_prediction": True,
            "predicted_amount_ml": round(predicted_amount, 0),
            "confidence": round(confidence, 0),
            "current_context": {
                "hour": current_hour,
                "hours_since_last": round(hours_since, 1)
            },
            "avg_amount_ml": round(np.mean(y), 0),
            "model_score": round(score, 2)
        }
        return clean_numpy(result)
    @staticmethod
    def identify_routine_clusters(activities: List[Activity]) -> Dict[str, Any]:
        """Identify daily routine patterns using K-Means clustering"""
        if len(activities) < 20:
            return {
                "has_analysis": False,
                "message": "Necesitas al menos 20 registros para análisis de rutinas"
            }
        
        daily_patterns = {}
        for activity in activities:
            date_key = activity.timestamp.date()
            if date_key not in daily_patterns:
                daily_patterns[date_key] = {
                    'feeding_count': 0,
                    'sleep_hours': 0,
                    'diaper_count': 0,
                    'total_activities': 0
                }
            
            daily_patterns[date_key]['total_activities'] += 1
            
            if activity.type == 'feeding':
                daily_patterns[date_key]['feeding_count'] += 1
            elif activity.type == 'sleep' and activity.data:
                daily_patterns[date_key]['sleep_hours'] += activity.data.get('duration_hours', 0)
            elif activity.type == 'diaper':
                daily_patterns[date_key]['diaper_count'] += 1
        
        if len(daily_patterns) < 3:
            return {"has_analysis": False}
        
        X = []
        dates = []
        for date, pattern in daily_patterns.items():
            X.append([
                pattern['feeding_count'],
                pattern['sleep_hours'],
                pattern['diaper_count']
            ])
            dates.append(date)
        
        X = np.array(X)
        
        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)
        
        n_clusters = min(3, len(X))
        kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
        labels = kmeans.fit_predict(X_scaled)
        
        clusters_info = []
        for i in range(n_clusters):
            cluster_indices = np.where(labels == i)[0]
            cluster_data = X[cluster_indices]
            
            avg_feeding = np.mean(cluster_data[:, 0])
            avg_sleep = np.mean(cluster_data[:, 1])
            avg_diaper = np.mean(cluster_data[:, 2])
            
            if avg_sleep > np.mean(X[:, 1]) + 0.5:
                cluster_type = "Días de mucho sueño"
            elif avg_feeding > np.mean(X[:, 0]) + 1:
                cluster_type = "Días de alimentación frecuente"
            else:
                cluster_type = "Días de rutina normal"
            
            clusters_info.append({
                "cluster_id": int(i),
                "type": cluster_type,
                "days_count": len(cluster_indices),
                "avg_feeding": round(avg_feeding, 1),
                "avg_sleep_hours": round(avg_sleep, 1),
                "avg_diaper": round(avg_diaper, 1)
            })
        
        if len(X) > 0:
            current_pattern = X[-1]
            current_pattern_scaled = scaler.transform([current_pattern])
            current_cluster = kmeans.predict(current_pattern_scaled)[0]
        else:
            current_cluster = 0
        
        result = {
            "has_analysis": True,
            "total_days_analyzed": len(daily_patterns),
            "clusters": clusters_info,
            "current_cluster": int(current_cluster),
            "current_pattern_type": clusters_info[current_cluster]["type"] if current_cluster < len(clusters_info) else "Desconocido"
        }
        return clean_numpy(result)
    
    @staticmethod
    def analyze_feeding_sleep_correlation(activities: List[Activity]) -> Dict[str, Any]:
        """Analyze correlation between feeding and sleep patterns"""
        feeding_activities = [a for a in activities if a.type == 'feeding']
        sleep_activities = [a for a in activities if a.type == 'sleep']
        
        if len(feeding_activities) < 5 or len(sleep_activities) < 5:
            return {
                "has_analysis": False,
                "message": "Necesitas al menos 5 registros de cada tipo"
            }
        
        daily_data = {}
        
        for activity in feeding_activities:
            date_key = activity.timestamp.date()
            if date_key not in daily_data:
                daily_data[date_key] = {'feeding_count': 0, 'feeding_amount': 0, 'sleep_hours': 0}
            daily_data[date_key]['feeding_count'] += 1
            if activity.data and 'quantity_ml' in activity.data:
                daily_data[date_key]['feeding_amount'] += activity.data['quantity_ml']
        
        for activity in sleep_activities:
            date_key = activity.timestamp.date()
            if date_key not in daily_data:
                daily_data[date_key] = {'feeding_count': 0, 'feeding_amount': 0, 'sleep_hours': 0}
            if activity.data:
                daily_data[date_key]['sleep_hours'] += activity.data.get('duration_hours', 0)
        
        valid_days = {k: v for k, v in daily_data.items() if v['feeding_count'] > 0 and v['sleep_hours'] > 0}
        
        if len(valid_days) < 3:
            return {"has_analysis": False}
        
        feeding_counts = [v['feeding_count'] for v in valid_days.values()]
        feeding_amounts = [v['feeding_amount'] for v in valid_days.values()]
        sleep_hours = [v['sleep_hours'] for v in valid_days.values()]
        
        corr_count, p_count = pearsonr(feeding_counts, sleep_hours) if len(feeding_counts) > 2 else (0, 1)
        
        if all(a > 0 for a in feeding_amounts):
            corr_amount, p_amount = pearsonr(feeding_amounts, sleep_hours) if len(feeding_amounts) > 2 else (0, 1)
        else:
            corr_amount, p_amount = 0, 1
        
        def interpret_correlation(corr):
            if abs(corr) < 0.3:
                return "débil"
            elif abs(corr) < 0.7:
                return "moderada"
            else:
                return "fuerte"
        
        insights = []
        
        if abs(corr_count) > 0.3:
            direction = "positiva" if corr_count > 0 else "negativa"
            strength = interpret_correlation(corr_count)
            insights.append(f"Correlación {strength} {direction} entre frecuencia de tomas y horas de sueño")
        
        if abs(corr_amount) > 0.3:
            direction = "positiva" if corr_amount > 0 else "negativa"
            strength = interpret_correlation(corr_amount)
            insights.append(f"Correlación {strength} {direction} entre cantidad de alimento y duración del sueño")
        
        result = {
            "has_analysis": True,
            "days_analyzed": len(valid_days),
            "correlation_frequency_sleep": round(corr_count, 2),
            "correlation_amount_sleep": round(corr_amount, 2),
            "insights": insights if insights else ["No se detectaron correlaciones significativas"],
            "avg_feeding_per_day": round(np.mean(feeding_counts), 1),
            "avg_sleep_per_day": round(np.mean(sleep_hours), 1)
        }
        return clean_numpy(result)
    
    @staticmethod
    def predict_diaper_change(activities: List[Activity]) -> Dict[str, Any]:
        """Predict next diaper change"""
        diaper_activities = [a for a in activities if a.type == 'diaper']
        
        if len(diaper_activities) < 5:
            return {
                "has_prediction": False,
                "message": "Necesitas al menos 5 registros de pañal"
            }
        
        diaper_activities.sort(key=lambda x: x.timestamp)
        intervals = []
        for i in range(1, len(diaper_activities)):
            hours = (diaper_activities[i].timestamp - diaper_activities[i-1].timestamp).total_seconds() / 3600
            intervals.append(hours)
        
        if not intervals:
            return {"has_prediction": False}
        
        avg_interval = np.mean(intervals)
        std_interval = np.std(intervals) if len(intervals) > 1 else 0
        
        last_diaper = diaper_activities[-1]
        last_diaper_time = last_diaper.timestamp
        hours_since = (datetime.now(timezone.utc) - last_diaper_time).total_seconds() / 3600
        
        predicted_next = last_diaper_time + timedelta(hours=avg_interval)
        minutes_until = (predicted_next - datetime.now(timezone.utc)).total_seconds() / 60
        
        if hours_since >= avg_interval:
            probability = min(95, 50 + (hours_since - avg_interval) * 20)
        else:
            probability = (hours_since / avg_interval) * 50
        
        result = {
            "has_prediction": True,
            "avg_interval_hours": round(avg_interval, 1),
            "hours_since_last": round(hours_since, 1),
            "minutes_until_next": round(max(0, minutes_until), 0),
            "probability": round(probability, 0),
            "is_overdue": hours_since > avg_interval,
            "predicted_time": predicted_next.isoformat()
        }
        return clean_numpy(result)
    
    @staticmethod
    def forecast_next_week(activities: List[Activity]) -> Dict[str, Any]:
        """Forecast patterns for the next week using time series analysis"""
        if len(activities) < 14:
            return {
                "has_forecast": False,
                "message": "Necesitas al menos 14 días de datos para forecasting"
            }
        
        daily_counts = {}
        for activity in activities:
            date_key = activity.timestamp.date()
            if date_key not in daily_counts:
                daily_counts[date_key] = {'feeding': 0, 'sleep_hours': 0, 'diaper': 0}
            
            if activity.type == 'feeding':
                daily_counts[date_key]['feeding'] += 1
            elif activity.type == 'sleep' and activity.data:
                daily_counts[date_key]['sleep_hours'] += activity.data.get('duration_hours', 0)
            elif activity.type == 'diaper':
                daily_counts[date_key]['diaper'] += 1
        
        if len(daily_counts) < 7:
            return {"has_forecast": False}
        
        sorted_dates = sorted(daily_counts.keys())
        
        feeding_values = [daily_counts[d]['feeding'] for d in sorted_dates]
        sleep_values = [daily_counts[d]['sleep_hours'] for d in sorted_dates]
        diaper_values = [daily_counts[d]['diaper'] for d in sorted_dates]
        
        window = min(7, len(feeding_values))
        
        forecast_feeding = round(np.mean(feeding_values[-window:]), 1)
        forecast_sleep = round(np.mean(sleep_values[-window:]), 1)
        forecast_diaper = round(np.mean(diaper_values[-window:]), 1)
        
        if len(feeding_values) >= 7:
            recent_avg = np.mean(feeding_values[-3:])
            older_avg = np.mean(feeding_values[-7:-3]) if len(feeding_values) > 3 else recent_avg
            feeding_trend = "creciente" if recent_avg > older_avg * 1.1 else "decreciente" if recent_avg < older_avg * 0.9 else "estable"
        else:
            feeding_trend = "estable"
        
        result = {
            "has_forecast": True,
            "days_analyzed": len(daily_counts),
            "next_week_forecast": {
                "feeding_per_day": forecast_feeding,
                "sleep_hours_per_day": forecast_sleep,
                "diaper_per_day": forecast_diaper
            },
            "trends": {
                "feeding": feeding_trend
            },
            "confidence": "media" if len(daily_counts) < 14 else "alta"
        }
        return clean_numpy(result)
    
    @staticmethod
    def _get_sleep_recommendation(quality: str) -> str:
        """Get recommendation based on sleep quality"""
        recommendations = {
            "Excelente": "¡Excelente trabajo! Mantén esta rutina de sueño constante.",
            "Buena": "Muy bien. Intenta mantener horarios consistentes para mejorar aún más.",
            "Regular": "Considera establecer una rutina de sueño más estricta y un ambiente tranquilo.",
            "Necesita mejora": "Consulta con tu pediatra. Establece horarios fijos y revisa el ambiente de sueño."
        }
        return recommendations.get(quality, "")