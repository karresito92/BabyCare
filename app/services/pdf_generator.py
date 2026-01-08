from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT
from reportlab.pdfgen import canvas
from datetime import datetime
from io import BytesIO
from typing import List
from ..models.baby import Baby
from ..models.activity import Activity


class NumberedCanvas(canvas.Canvas):
    """Canvas personalizado con número de página y header"""
    def __init__(self, *args, **kwargs):
        canvas.Canvas.__init__(self, *args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_number(num_pages)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)

    def draw_page_number(self, page_count):
        # Header con línea decorativa
        self.setStrokeColor(colors.HexColor('#6BA3E8'))
        self.setLineWidth(2)
        self.line(2*cm, A4[1] - 1.5*cm, A4[0] - 2*cm, A4[1] - 1.5*cm)
        
        # Footer con número de página
        self.setFont('Helvetica', 9)
        self.setFillColor(colors.grey)
        page_num = f"Página {self._pageNumber} de {page_count}"
        self.drawRightString(A4[0] - 2*cm, 1.5*cm, page_num)
        
        # Logo/Marca BabyCare
        self.setFont('Helvetica-Bold', 10)
        self.setFillColor(colors.HexColor('#6BA3E8'))
        self.drawString(2*cm, 1.5*cm, "BabyCare")


def generate_pediatric_report(baby: Baby, activities: List[Activity], start_date: datetime, end_date: datetime) -> BytesIO:
    """
    Genera un informe médico premium en PDF para el pediatra
    """
    
    buffer = BytesIO()
    doc = SimpleDocTemplate(
        buffer, 
        pagesize=A4, 
        topMargin=2.5*cm, 
        bottomMargin=2.5*cm,
        leftMargin=2*cm,
        rightMargin=2*cm
    )
    
    styles = getSampleStyleSheet()
    
    # ========== ESTILOS PERSONALIZADOS PREMIUM ==========
    
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=28,
        textColor=colors.HexColor('#6BA3E8'),
        spaceAfter=10,
        spaceBefore=20,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold',
        leading=34
    )
    
    subtitle_style = ParagraphStyle(
        'CustomSubtitle',
        parent=styles['Normal'],
        fontSize=12,
        textColor=colors.HexColor('#666666'),
        spaceAfter=30,
        alignment=TA_CENTER,
        fontName='Helvetica',
    )
    
    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=16,
        textColor=colors.HexColor('#1A1A1A'),
        spaceAfter=16,
        spaceBefore=20,
        fontName='Helvetica-Bold',
        borderWidth=0,
        borderColor=colors.HexColor('#6BA3E8'),
        borderPadding=8,
        backColor=colors.HexColor('#F0F7FF'),
        leftIndent=10
    )
    
    normal_bold = ParagraphStyle(
        'NormalBold',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10
    )
    
    # ========== CONTENIDO DEL PDF ==========
    story = []
    
    # ========== PORTADA ==========
    story.append(Spacer(1, 2*cm))
    
    # Título principal con diseño moderno
    story.append(Paragraph("INFORME PEDIÁTRICO", title_style))
    story.append(Paragraph("Registro de Cuidado Infantil", subtitle_style))
    
    # Caja decorativa con información del bebé
    story.append(Spacer(1, 1*cm))
    
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
    
    # Información del paciente en caja destacada
    patient_info = [
        ["DATOS DEL PACIENTE", ""],
    ]
    
    patient_data = [
        ["Nombre:", baby.name],
        ["Fecha de nacimiento:", baby.birth_date.strftime("%d/%m/%Y")],
        ["Edad:", age_str.strip()],
        ["Período del informe:", f"{start_date.strftime('%d/%m/%Y')} - {end_date.strftime('%d/%m/%Y')}"]
    ]
    
    # Tabla de encabezado
    header_table = Table(patient_info, colWidths=[15*cm])
    header_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor('#6BA3E8')),
        ('TEXTCOLOR', (0, 0), (-1, -1), colors.white),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 14),
        ('TOPPADDING', (0, 0), (-1, -1), 12),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 12),
    ]))
    
    story.append(header_table)
    
    # Tabla de datos del paciente
    patient_table = Table(patient_data, colWidths=[5*cm, 10*cm])
    patient_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#E8F4F8')),
        ('BACKGROUND', (1, 0), (1, -1), colors.white),
        ('TEXTCOLOR', (0, 0), (-1, -1), colors.HexColor('#1A1A1A')),
        ('ALIGN', (0, 0), (0, -1), 'RIGHT'),
        ('ALIGN', (1, 0), (1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 11),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
        ('TOPPADDING', (0, 0), (-1, -1), 10),
        ('LEFTPADDING', (0, 0), (-1, -1), 12),
        ('RIGHTPADDING', (0, 0), (-1, -1), 12),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#D0E8F2')),
        ('LINEBELOW', (0, 0), (-1, -2), 0.5, colors.HexColor('#E8F4F8')),
    ]))
    
    story.append(patient_table)
    story.append(Spacer(1, 1.5*cm))
    
    # ========== RESUMEN ESTADÍSTICO ==========
    story.append(Paragraph("RESUMEN ESTADÍSTICO", heading_style))
    story.append(Spacer(1, 0.3*cm))
    
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
    health_count = len([a for a in activities if a.type == "health" or a.type == "medical"])
    
    # Calcular promedios diarios
    days = max(1, (end_date - start_date).days + 1)
    
    stats_data = [
        ["Métrica", "Total", "Promedio Diario"],
        ["Tomas de alimento", str(feeding_count), f"{feeding_count/days:.1f}"],
        ["Cantidad total (ml)", f"{feeding_total_ml:.0f} ml", f"{feeding_total_ml/days:.0f} ml"],
        ["Horas de sueño", f"{sleep_total_hours:.1f}h", f"{sleep_total_hours/days:.1f}h"],
        ["Cambios de pañal", str(diaper_count), f"{diaper_count/days:.1f}"],
        ["Registros de salud", str(health_count), f"{health_count/days:.1f}"],
    ]
    
    stats_table = Table(stats_data, colWidths=[7*cm, 4*cm, 4*cm])
    stats_table.setStyle(TableStyle([
        # Header
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#6BA3E8')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 12),
        ('TOPPADDING', (0, 0), (-1, 0), 12),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        
        # Body
        ('BACKGROUND', (0, 1), (-1, -1), colors.white),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F9FAFB')]),
        ('TEXTCOLOR', (0, 1), (-1, -1), colors.HexColor('#1A1A1A')),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 1), (-1, -1), 10),
        ('TOPPADDING', (0, 1), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 1), (-1, -1), 10),
        
        # Borders
        ('BOX', (0, 0), (-1, -1), 1.5, colors.HexColor('#6BA3E8')),
        ('LINEBELOW', (0, 0), (-1, 0), 1.5, colors.white),
        ('INNERGRID', (0, 1), (-1, -1), 0.5, colors.HexColor('#E5E7EB')),
    ]))
    
    story.append(stats_table)
    story.append(Spacer(1, 1*cm))
    
    # ========== DETALLE DE ALIMENTACIÓN ==========
    feeding_activities = [a for a in activities if a.type == "feeding"]
    if feeding_activities:
        story.append(Paragraph("DETALLE DE ALIMENTACIÓN", heading_style))
        story.append(Spacer(1, 0.3*cm))
        
        data = [['Fecha/Hora', 'Tipo', 'Cantidad', 'Notas']]
        
        for activity in feeding_activities[:15]:
            feed_type = activity.data.get('type', 'bottle') if activity.data else 'bottle'
            type_label = '🍼 Biberón' if feed_type == 'bottle' else '🤱 Pecho'
            quantity = f"{activity.data.get('quantity_ml', 'N/A')} ml" if activity.data else 'N/A'
            notes = activity.notes[:35] + '...' if activity.notes and len(activity.notes) > 35 else (activity.notes or '-')
            
            data.append([
                activity.timestamp.strftime('%d/%m %H:%M'),
                type_label,
                quantity,
                notes
            ])
        
        table = Table(data, colWidths=[3.5*cm, 3.5*cm, 2.5*cm, 5.5*cm])
        table.setStyle(TableStyle([
            # Header
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#4CAF50')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('ALIGN', (2, 0), (2, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('TOPPADDING', (0, 0), (-1, 0), 10),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 10),
            
            # Body
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F1F8F4')]),
            ('FONTSIZE', (0, 1), (-1, -1), 9),
            ('TOPPADDING', (0, 1), (-1, -1), 8),
            ('BOTTOMPADDING', (0, 1), (-1, -1), 8),
            ('LEFTPADDING', (0, 0), (-1, -1), 8),
            ('RIGHTPADDING', (0, 0), (-1, -1), 8),
            
            # Borders
            ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#4CAF50')),
            ('LINEBELOW', (0, 0), (-1, 0), 1.5, colors.white),
            ('INNERGRID', (0, 1), (-1, -1), 0.5, colors.HexColor('#E8F5E9')),
        ]))
        
        story.append(table)
        story.append(Spacer(1, 0.8*cm))
    
    # ========== DETALLE DE SUEÑO ==========
    if sleep_activities:
        story.append(Paragraph("DETALLE DE SUEÑO", heading_style))
        story.append(Spacer(1, 0.3*cm))
        
        data = [['Fecha/Hora', 'Duración', 'Notas']]
        
        for activity in sleep_activities[:15]:
            duration = f"{activity.data.get('duration_hours', 'N/A')}h" if activity.data else 'N/A'
            notes = activity.notes[:50] + '...' if activity.notes and len(activity.notes) > 50 else (activity.notes or '-')
            
            data.append([
                activity.timestamp.strftime('%d/%m %H:%M'),
                duration,
                notes
            ])
        
        table = Table(data, colWidths=[3.5*cm, 2.5*cm, 9*cm])
        table.setStyle(TableStyle([
            # Header
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#9C27B0')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('ALIGN', (1, 0), (1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('TOPPADDING', (0, 0), (-1, 0), 10),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 10),
            
            # Body
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F3E5F5')]),
            ('FONTSIZE', (0, 1), (-1, -1), 9),
            ('TOPPADDING', (0, 1), (-1, -1), 8),
            ('BOTTOMPADDING', (0, 1), (-1, -1), 8),
            ('LEFTPADDING', (0, 0), (-1, -1), 8),
            ('RIGHTPADDING', (0, 0), (-1, -1), 8),
            
            # Borders
            ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#9C27B0')),
            ('LINEBELOW', (0, 0), (-1, 0), 1.5, colors.white),
            ('INNERGRID', (0, 1), (-1, -1), 0.5, colors.HexColor('#E1BEE7')),
        ]))
        
        story.append(table)
        story.append(Spacer(1, 0.8*cm))
    
    # ========== REGISTROS DE SALUD ==========
    health_activities = [a for a in activities if a.type == "health" or a.type == "medical"]
    if health_activities:
        story.append(Paragraph("REGISTROS DE SALUD Y MEDICAMENTOS", heading_style))
        story.append(Spacer(1, 0.3*cm))
        
        data = [['Fecha/Hora', 'Tipo', 'Detalles']]
        
        for activity in health_activities:
            details = []
            if activity.data:
                if 'temperature' in activity.data:
                    details.append(f"🌡️ {activity.data['temperature']}°C")
                if 'medication' in activity.data:
                    details.append(f"💊 {activity.data['medication']}")
                if 'dosage' in activity.data:
                    details.append(f"Dosis: {activity.data['dosage']}")
                if 'reason' in activity.data:
                    details.append(f"Motivo: {activity.data['reason']}")
            
            detail_str = ' | '.join(details) if details else 'Registro general de salud'
            if len(detail_str) > 60:
                detail_str = detail_str[:60] + '...'
            
            notes = activity.notes[:30] + '...' if activity.notes and len(activity.notes) > 30 else (activity.notes or '-')
            
            data.append([
                activity.timestamp.strftime('%d/%m %H:%M'),
                '🏥 Consulta' if activity.type == 'medical' else '💊 Medicación',
                detail_str if detail_str else notes
            ])
        
        table = Table(data, colWidths=[3.5*cm, 3*cm, 8.5*cm])
        table.setStyle(TableStyle([
            # Header
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#FF5252')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('TOPPADDING', (0, 0), (-1, 0), 10),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 10),
            
            # Body
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#FFEBEE')]),
            ('FONTSIZE', (0, 1), (-1, -1), 9),
            ('TOPPADDING', (0, 1), (-1, -1), 8),
            ('BOTTOMPADDING', (0, 1), (-1, -1), 8),
            ('LEFTPADDING', (0, 0), (-1, -1), 8),
            ('RIGHTPADDING', (0, 0), (-1, -1), 8),
            
            # Borders
            ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#FF5252')),
            ('LINEBELOW', (0, 0), (-1, 0), 1.5, colors.white),
            ('INNERGRID', (0, 1), (-1, -1), 0.5, colors.HexColor('#FFCDD2')),
        ]))
        
        story.append(table)
        story.append(Spacer(1, 0.8*cm))
    
    # ========== OBSERVACIONES IMPORTANTES ==========
    activities_with_notes = [a for a in activities if a.notes and a.notes.strip()]
    if activities_with_notes:
        story.append(Paragraph("OBSERVACIONES IMPORTANTES", heading_style))
        story.append(Spacer(1, 0.3*cm))
        
        for activity in activities_with_notes[:5]:
            date_str = activity.timestamp.strftime('%d/%m/%Y %H:%M')
            type_labels = {
                'feeding': '🍼 Alimentación',
                'sleep': '😴 Sueño',
                'diaper': '🧷 Pañal',
                'health': '🏥 Salud',
                'medical': '💊 Médico'
            }
            type_label = type_labels.get(activity.type, activity.type)
            
            # Crear caja de observación
            obs_data = [[f"{date_str} - {type_label}", activity.notes]]
            obs_table = Table(obs_data, colWidths=[4*cm, 11*cm])
            obs_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (0, 0), colors.HexColor('#F0F7FF')),
                ('BACKGROUND', (1, 0), (1, 0), colors.white),
                ('TEXTCOLOR', (0, 0), (-1, -1), colors.HexColor('#1A1A1A')),
                ('FONTNAME', (0, 0), (0, 0), 'Helvetica-Bold'),
                ('FONTNAME', (1, 0), (1, 0), 'Helvetica'),
                ('FONTSIZE', (0, 0), (-1, -1), 9),
                ('ALIGN', (0, 0), (0, 0), 'LEFT'),
                ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                ('TOPPADDING', (0, 0), (-1, -1), 8),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
                ('LEFTPADDING', (0, 0), (-1, -1), 8),
                ('RIGHTPADDING', (0, 0), (-1, -1), 8),
                ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor('#D0E8F2')),
            ]))
            story.append(obs_table)
            story.append(Spacer(1, 0.3*cm))
    
    # ========== ESPACIO PARA PROFESIONAL ==========
    story.append(Spacer(1, 1*cm))
    story.append(Paragraph("OBSERVACIONES DEL PROFESIONAL SANITARIO", heading_style))
    story.append(Spacer(1, 0.5*cm))
    
    # Caja para observaciones
    obs_box = Table([[""] * 1] * 8, colWidths=[15*cm], rowHeights=[0.8*cm] * 8)
    obs_box.setStyle(TableStyle([
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#D0E8F2')),
        ('LINEBELOW', (0, 0), (-1, -2), 0.5, colors.HexColor('#E8F4F8')),
        ('BACKGROUND', (0, 0), (-1, -1), colors.white),
    ]))
    story.append(obs_box)
    
    # ========== PIE DE PÁGINA ==========
    story.append(Spacer(1, 1.5*cm))
    
    footer_data = [[
        f"📅 Informe generado el {datetime.now().strftime('%d/%m/%Y a las %H:%M')}",
        ""
    ]]
    
    footer_table = Table(footer_data, colWidths=[15*cm])
    footer_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor('#F0F7FF')),
        ('TEXTCOLOR', (0, 0), (-1, -1), colors.HexColor('#666666')),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('TOPPADDING', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#D0E8F2')),
    ]))
    story.append(footer_table)
    
    # ========== CONSTRUIR PDF CON CANVAS PERSONALIZADO ==========
    doc.build(story, canvasmaker=NumberedCanvas)
    buffer.seek(0)
    
    return buffer