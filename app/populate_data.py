import random
from datetime import datetime, timedelta
from sqlalchemy.orm import Session

from .database import SessionLocal
from .models.user import User
from .models.baby import Baby
from .models.user_baby import UserBaby
from .models.activity import Activity


def populate_data():
    """Populate database with realistic test data"""
    db = SessionLocal()
    
    try:
        print("🚀 Iniciando población de datos de prueba...")
        
        # Get existing user and baby (assumes you have test@test.com)
        user = db.query(User).filter(User.email == "test@test.com").first()
        
        if not user:
            print("❌ Usuario test@test.com no encontrado. Créalo primero.")
            return
        
        # Get baby
        user_babies = db.query(UserBaby).filter(UserBaby.user_id == user.id).all()
        if not user_babies:
            print("❌ No hay bebés asociados al usuario. Crea uno primero.")
            return
        
        baby = db.query(Baby).filter(Baby.id == user_babies[0].baby_id).first()
        print(f"✅ Usando bebé: {baby.name} (ID: {baby.id})")
        
        # Delete existing activities for this baby
        existing_count = db.query(Activity).filter(Activity.baby_id == baby.id).count()
        db.query(Activity).filter(Activity.baby_id == baby.id).delete()
        db.commit()
        print(f"🗑️  Eliminados {existing_count} registros anteriores")
        
        # Generate 30 days of realistic data
        end_date = datetime.now()
        start_date = end_date - timedelta(days=30)
        
        activities = []
        current_date = start_date
        
        print("📊 Generando 30 días de datos realistas...")
        
        day_count = 0
        while current_date <= end_date:
            day_count += 1
            
            # FEEDING: 6-8 times per day, every 2.5-4 hours
            num_feedings = random.randint(6, 8)
            feeding_hours = sorted([random.uniform(0, 24) for _ in range(num_feedings)])
            
            for hour in feeding_hours:
                timestamp = current_date.replace(
                    hour=int(hour),
                    minute=random.randint(0, 59),
                    second=0,
                    microsecond=0
                )
                
                # Quantity: 120-200ml with some variation
                base_quantity = 150
                quantity = base_quantity + random.randint(-30, 50)
                
                # Add some anomalies (5% of the time)
                if random.random() < 0.05:
                    quantity = random.choice([80, 220])  # Anomaly
                
                activities.append(Activity(
                    baby_id=baby.id,
                    user_id=user.id,
                    type='feeding',
                    timestamp=timestamp,
                    data={
                        'quantity_ml': quantity,
                        'type': random.choice(['breast', 'bottle', 'bottle'])
                    },
                    notes=random.choice([
                        None, None, None,  # Most without notes
                        'Buena toma',
                        'Se quedó con hambre',
                        'Tomó todo',
                    ])
                ))
            
            # SLEEP: 4-6 sessions per day
            num_sleeps = random.randint(4, 6)
            sleep_times = sorted([random.uniform(0, 24) for _ in range(num_sleeps)])
            
            for hour in sleep_times:
                timestamp = current_date.replace(
                    hour=int(hour),
                    minute=random.randint(0, 59),
                    second=0,
                    microsecond=0
                )
                
                # Duration: varies by time of day
                if 20 <= hour or hour <= 6:  # Night sleep
                    duration = random.uniform(3, 6)
                else:  # Day naps
                    duration = random.uniform(0.5, 2.5)
                
                activities.append(Activity(
                    baby_id=baby.id,
                    user_id=user.id,
                    type='sleep',
                    timestamp=timestamp,
                    data={
                        'duration_hours': round(duration, 2)
                    },
                    notes=random.choice([
                        None, None, None,
                        'Durmió bien',
                        'Se despertó varias veces',
                        'Sueño tranquilo',
                    ])
                ))
            
            # DIAPER: 6-10 changes per day
            num_diapers = random.randint(6, 10)
            diaper_times = sorted([random.uniform(0, 24) for _ in range(num_diapers)])
            
            for hour in diaper_times:
                timestamp = current_date.replace(
                    hour=int(hour),
                    minute=random.randint(0, 59),
                    second=0,
                    microsecond=0
                )
                
                activities.append(Activity(
                    baby_id=baby.id,
                    user_id=user.id,
                    type='diaper',
                    timestamp=timestamp,
                    data={
                        'type': random.choice(['wet', 'wet', 'dirty', 'both'])
                    },
                    notes=None
                ))
            
            # HEALTH: Occasional entries (10% of days)
            if random.random() < 0.1:
                timestamp = current_date.replace(
                    hour=random.randint(8, 20),
                    minute=random.randint(0, 59),
                    second=0,
                    microsecond=0
                )
                
                activities.append(Activity(
                    baby_id=baby.id,
                    user_id=user.id,
                    type='health',
                    timestamp=timestamp,
                    data={
                        'temperature': round(random.uniform(36.5, 37.5), 1),
                        'weight': round(random.uniform(4.5, 6.5), 2)
                    },
                    notes=random.choice([
                        'Control rutinario',
                        'Todo normal',
                        'Revisión',
                    ])
                ))
            
            current_date += timedelta(days=1)
            
            if day_count % 5 == 0:
                print(f"  ✓ {day_count} días procesados...")
        
        # Bulk insert
        print(f"💾 Insertando {len(activities)} actividades en la base de datos...")
        db.bulk_save_objects(activities)
        db.commit()
        
        # Summary
        print("\n" + "="*50)
        print("✅ DATOS DE PRUEBA CREADOS EXITOSAMENTE")
        print("="*50)
        
        feeding_count = len([a for a in activities if a.type == 'feeding'])
        sleep_count = len([a for a in activities if a.type == 'sleep'])
        diaper_count = len([a for a in activities if a.type == 'diaper'])
        health_count = len([a for a in activities if a.type == 'health'])
        
        print(f"📊 Estadísticas:")
        print(f"   • Periodo: 30 días")
        print(f"   • Alimentación: {feeding_count} registros")
        print(f"   • Sueño: {sleep_count} registros")
        print(f"   • Pañales: {diaper_count} registros")
        print(f"   • Salud: {health_count} registros")
        print(f"   • TOTAL: {len(activities)} registros")
        print(f"\n✨ Ahora deberías ver los 9 modelos ML activos!")
        print("="*50 + "\n")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    populate_data()