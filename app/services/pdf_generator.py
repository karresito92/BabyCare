from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from datetime import datetime
from io import BytesIO
from typing import List
from ..models.baby import Baby
from ..models.activity import Activity


def generate_pediatric_report(baby: Baby, activities: List[Activity], start_date: datetime, end_date: datetime) -> BytesIO:
    """
    Genera un informe médico en PDF para el pediatra
    """
    
    buffer = BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4, topMargin=2*cm, bottomMargin=2*cm)
    
    styles = getSampleStyleSheet()
    
    # Estilos personalizados
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#6BA3E8'),
        spaceAfter=30,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    )
    
    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=14,
        textColor=colors.HexColor('#1A1A1A'),
        spaceAfter=12,
        spaceBefore=12,
        fontName='Helvetica-Bold'
    )
    
    # Contenido del PDF
    story = []
    
    # Título
    story.append(Paragraph("INFORME DE CUIDADO INFANTIL", title_style))
    story.append(Spacer(1, 0.5*cm))
    
    # Información del bebé
    story.append(Paragraph("DATOS DEL PACIENTE", heading_style))
    
    # Calcular edad
    today = datetime.now().date()
    age = today - baby.birth_date
    years = age.days // 365
    months = (age.days % 365) // 30
    days = (age.days % 365) % 30
    
    age_str = ""
    if years > 0:
        age_str += f"{years} año{'s' if years > 1 else ''} "
    if months > 0:
        age_str += f"{months} mes{'es' if months > 1 else ''} "
    if days > 0 or age_str == "":
        age_str += f"{days} día{'s' if days != 1 else ''}"
    
    baby_data = [
        ["Nombre:", baby.name],
        ["Fecha de nacimiento:", baby.birth_date.strftime("%d/%m/%Y")],
        ["Edad:", age_str.strip()],
        ["Período del informe:", f"{start_date.strftime('%d/%m/%Y')} - {end_date.strftime('%d/%m/%Y')}"]
    ]
    
    baby_table = Table(baby_data, colWidths=[5*cm, 10*cm])
    baby_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#F0F0F0')),
        ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 11),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.grey)
    ]))
    
    story.append(baby_table)
    story.append(Spacer(1, 0.8*cm))
    
    # Resumen estadístico
    story.append(Paragraph("RESUMEN ESTADÍSTICO", heading_style))
    
    # Calcular estadísticas
    feeding_count = len([a for a in activities if a.type == "feeding"])
    feeding_total_ml = sum([
        a.data.get('quantity_ml', 0) 
        for a in activities 
        if a.type == 'feeding' and a.data
    ])
    
    sleep_activities = [a for a in activities if a.type == "sleep"]
    sleep_total_hours = sum([
        a.data.get('duration_hours', 0) 
        for a in sleep_activities 
        if a.data
    ])
    
    diaper_count = len([a for a in activities if a.type == "diaper"])
    health_count = len([a for a in activities if a.type == "health"])
    
    # Calcular promedios diarios
    days = max(1, (end_date - start_date).days + 1)
    
    stats_data = [
        ["Métrica", "Total", "Promedio Diario"],
        ["Tomas de alimento", str(feeding_count), f"{feeding_count/days:.1f}"],
        ["Cantidad total (ml)", str(feeding_total_ml), f"{feeding_total_ml/days:.0f} ml"],
        ["Horas de sueño", f"{sleep_total_hours:.1f}h", f"{sleep_total_hours/days:.1f}h"],
        ["Cambios de pañal", str(diaper_count), f"{diaper_count/days:.1f}"],
        ["Registros de salud", str(health_count), f"{health_count/days:.1f}"],
    ]
    
    stats_table = Table(stats_data, colWidths=[7*cm, 4*cm, 4*cm])
    stats_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#6BA3E8')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 12),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 10),
        ('TOPPADDING', (0, 0), (-1, 0), 10),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.grey),
        ('FONTSIZE', (0, 1), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 1), (-1, -1), 8),
        ('TOPPADDING', (0, 1), (-1, -1), 8),
    ]))
    
    story.append(stats_table)
    story.append(Spacer(1, 0.8*cm))
    
    # Detalle de alimentación
    feeding_activities = [a for a in activities if a.type == "feeding"]
    if feeding_activities:
        story.append(Paragraph("DETALLE DE ALIMENTACIÓN", heading_style))
        
        data = [['Fecha/Hora', 'Tipo', 'Cantidad', 'Notas']]
        
        for activity in feeding_activities[:10]:  # Últimas 10
            feed_type = activity.data.get('type', 'bottle') if activity.data else 'bottle'
            type_label = 'Biberón' if feed_type == 'bottle' else 'Pecho'
            quantity = f"{activity.data.get('quantity_ml', 'N/A')}ml" if activity.data else 'N/A'
            notes = activity.notes[:30] + '...' if activity.notes and len(activity.notes) > 30 else (activity.notes or '-')
            
            data.append([
                activity.timestamp.strftime('%d/%m %H:%M'),
                type_label,
                quantity,
                notes
            ])
        
        table = Table(data, colWidths=[3.5*cm, 3*cm, 3*cm, 5.5*cm])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#6BA3E8')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('FONTSIZE', (0, 1), (-1, -1), 9),
        ]))
        
        story.append(table)
        story.append(Spacer(1, 0.5*cm))
    
    # Detalle de sueño
    if sleep_activities:
        story.append(Paragraph("DETALLE DE SUEÑO", heading_style))
        
        data = [['Fecha/Hora', 'Duración', 'Notas']]
        
        for activity in sleep_activities[:10]:
            duration = f"{activity.data.get('duration_hours', 'N/A')}h" if activity.data else 'N/A'
            notes = activity.notes[:40] + '...' if activity.notes and len(activity.notes) > 40 else (activity.notes or '-')
            
            data.append([
                activity.timestamp.strftime('%d/%m %H:%M'),
                duration,
                notes
            ])
        
        table = Table(data, colWidths=[3.5*cm, 3*cm, 8.5*cm])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#9C27B0')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('FONTSIZE', (0, 1), (-1, -1), 9),
        ]))
        
        story.append(table)
        story.append(Spacer(1, 0.5*cm))
    
    # Registros de salud
    health_activities = [a for a in activities if a.type == "health"]
    if health_activities:
        story.append(Paragraph("REGISTROS DE SALUD Y MEDICAMENTOS", heading_style))
        
        data = [['Fecha/Hora', 'Detalles', 'Notas']]
        
        for activity in health_activities:
            details = []
            if activity.data:
                if 'temperature' in activity.data:
                    details.append(f"Temp: {activity.data['temperature']}°C")
                if 'medication' in activity.data:
                    details.append(f"Med: {activity.data['medication']}")
                if 'dosage' in activity.data:
                    details.append(f"Dosis: {activity.data['dosage']}")
            
            detail_str = ', '.join(details) if details else 'Registro general'
            notes = activity.notes[:40] + '...' if activity.notes and len(activity.notes) > 40 else (activity.notes or '-')
            
            data.append([
                activity.timestamp.strftime('%d/%m %H:%M'),
                detail_str,
                notes
            ])
        
        table = Table(data, colWidths=[3.5*cm, 5*cm, 6.5*cm])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#FF5252')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('FONTSIZE', (0, 1), (-1, -1), 9),
        ]))
        
        story.append(table)
        story.append(Spacer(1, 0.5*cm))
    
    # Observaciones importantes
    activities_with_notes = [a for a in activities if a.notes and a.notes.strip()]
    if activities_with_notes:
        story.append(Paragraph("OBSERVACIONES IMPORTANTES", heading_style))
        
        for activity in activities_with_notes[:5]:
            date_str = activity.timestamp.strftime('%d/%m/%Y %H:%M')
            type_labels = {
                'feeding': 'Alimentación',
                'sleep': 'Sueño',
                'diaper': 'Pañal',
                'health': 'Salud'
            }
            type_label = type_labels.get(activity.type, activity.type)
            
            story.append(Paragraph(
                f"<b>{date_str} - {type_label}:</b> {activity.notes}",
                styles['Normal']
            ))
            story.append(Spacer(1, 0.2*cm))
    
    # Espacio para observaciones del profesional
    story.append(Spacer(1, 0.8*cm))
    story.append(Paragraph("OBSERVACIONES DEL PROFESIONAL SANITARIO", heading_style))
    story.append(Spacer(1, 0.3*cm))
    
    obs_lines = ["_" * 100] * 6
    for line in obs_lines:
        story.append(Paragraph(line, styles['Normal']))
        story.append(Spacer(1, 0.3*cm))
    
    # Pie de página
    story.append(Spacer(1, 1*cm))
    footer_text = f"Informe generado el {datetime.now().strftime('%d/%m/%Y a las %H:%M')}<br/>BabyCare - Aplicación de seguimiento de cuidado infantil"
    story.append(Paragraph(
        footer_text,
        ParagraphStyle('Footer', parent=styles['Normal'], fontSize=8, textColor=colors.grey, alignment=TA_CENTER)
    ))
    
    # Construir PDF
    doc.build(story)
    buffer.seek(0)
    
    return buffer