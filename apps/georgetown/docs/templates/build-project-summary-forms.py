#!/usr/bin/env python3
"""Build RC Georgetown Project Summary Word forms with proper form styling."""
from docx import Document
from docx.shared import Pt, RGBColor, Inches, Twips
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

AZURE   = RGBColor(0x00,0x67,0xC8)
ROYAL   = RGBColor(0x17,0x45,0x8F)
CHARCOAL= RGBColor(0x54,0x56,0x5A)
PALE    = "EAF1FB"   # label cell fill
AZURE_HEX="0067C8"
BORDER  = "C9CCD1"
BODY_FONT = "Open Sans"
HEAD_FONT = "Open Sans Condensed"

def set_cell_bg(cell, hex_fill):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd'); shd.set(qn('w:val'),'clear'); shd.set(qn('w:color'),'auto'); shd.set(qn('w:fill'),hex_fill)
    tcPr.append(shd)

def set_cell_borders(cell, color=BORDER, sz=6):
    tcPr = cell._tc.get_or_add_tcPr()
    borders = OxmlElement('w:tcBorders')
    for edge in ('top','left','bottom','right'):
        e = OxmlElement(f'w:{edge}')
        e.set(qn('w:val'),'single'); e.set(qn('w:sz'),str(sz)); e.set(qn('w:space'),'0'); e.set(qn('w:color'),color)
        borders.append(e)
    tcPr.append(borders)

def set_cell_margins(cell, top=80, bottom=80, left=120, right=120):
    tcPr = cell._tc.get_or_add_tcPr()
    m = OxmlElement('w:tcMar')
    for edge,val in (('top',top),('bottom',bottom),('left',left),('right',right)):
        e=OxmlElement(f'w:{edge}'); e.set(qn('w:w'),str(val)); e.set(qn('w:type'),'dxa'); m.append(e)
    tcPr.append(m)

def set_row_height(row, twips=560):
    trPr = row._tr.get_or_add_trPr()
    h=OxmlElement('w:trHeight'); h.set(qn('w:val'),str(twips)); h.set(qn('w:hRule'),'atLeast'); trPr.append(h)

def style_run(run, *, font=BODY_FONT, size=10.5, bold=False, italic=False, color=CHARCOAL):
    run.font.name=font; run.font.size=Pt(size); run.bold=bold; run.italic=italic; run.font.color.rgb=color
    # also set east-asian/cs font
    rpr=run._element.get_or_add_rPr(); rf=rpr.find(qn('w:rFonts'))
    if rf is None: rf=OxmlElement('w:rFonts'); rpr.insert(0,rf)
    for a in ('w:ascii','w:hAnsi','w:cs'): rf.set(qn(a),font)

def add_label(cell, parts):
    """parts: list of (text, {bold/italic}) tuples"""
    cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
    p = cell.paragraphs[0]; p.paragraph_format.space_after=Pt(0); p.paragraph_format.space_before=Pt(0)
    for text, opt in parts:
        r=p.add_run(text); style_run(r, bold=opt.get('bold',False), italic=opt.get('italic',False),
                                    color=opt.get('color',CHARCOAL), size=opt.get('size',10.5))

def add_answer(cell, text=""):
    cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
    p=cell.paragraphs[0]; p.paragraph_format.space_after=Pt(0); p.paragraph_format.space_before=Pt(0)
    if text:
        r=p.add_run(text); style_run(r, color=CHARCOAL)

def section(doc, title):
    h=doc.add_paragraph(); h.paragraph_format.space_before=Pt(16); h.paragraph_format.space_after=Pt(6)
    h.paragraph_format.keep_with_next=True
    r=h.add_run(title); style_run(r, font=HEAD_FONT, size=15, bold=True, color=AZURE)

def field_table(doc, rows, label_w=2.7, ans_w=3.8):
    """rows: list of (label_parts, answer_text)"""
    t=doc.add_table(rows=0, cols=2); t.alignment=WD_TABLE_ALIGNMENT.LEFT
    t.allow_autofit=False
    for label_parts, answer in rows:
        row=t.add_row(); set_row_height(row, 560)
        lc,ac=row.cells
        lc.width=Inches(label_w); ac.width=Inches(ans_w)
        set_cell_bg(lc, PALE)
        for c in (lc,ac):
            set_cell_borders(c); set_cell_margins(c)
        add_label(lc, label_parts); add_answer(ac, answer)
    # spacing after table
    sp=doc.add_paragraph(); sp.paragraph_format.space_after=Pt(2)
    return t

def L(bold_text, hint=None):
    parts=[(bold_text, {'bold':True})]
    if hint: parts.append((f"  {hint}", {'italic':True, 'color':RGBColor(0x89,0x8A,0x8D), 'size':9}))
    return parts

def build(path, *, draft_for=None, prefill=None):
    prefill = prefill or {}
    doc=Document()
    # base style
    st=doc.styles['Normal']; st.font.name=BODY_FONT; st.font.size=Pt(10.5); st.font.color.rgb=CHARCOAL
    st.paragraph_format.space_after=Pt(6); st.paragraph_format.line_spacing=1.15
    # margins
    sec=doc.sections[0]
    sec.top_margin=Inches(0.8); sec.bottom_margin=Inches(0.8); sec.left_margin=Inches(0.9); sec.right_margin=Inches(0.9)

    # Title
    tp=doc.add_paragraph(); tp.alignment=WD_ALIGN_PARAGRAPH.LEFT; tp.paragraph_format.space_after=Pt(2)
    tr=tp.add_run("RC Georgetown — Project Summary Form"); style_run(tr, font=HEAD_FONT, size=22, bold=True, color=ROYAL)
    if draft_for:
        sp=doc.add_paragraph(); sp.paragraph_format.space_after=Pt(8)
        sr=sp.add_run(f"{prefill.get('Project name','')} — draft for {draft_for}"); style_run(sr, font=HEAD_FONT, size=13, bold=False, color=AZURE)

    # Intro
    ip=doc.add_paragraph(); ip.paragraph_format.space_after=Pt(10)
    if draft_for:
        intro=("Hi Mike — we've pre-filled what we have on record. Please correct anything wrong and "
               "type your answers into the blank right-hand cells. Thank you!")
    else:
        intro=("Please complete the fields below — type directly into the right-hand cells. Blanks are fine; "
               "we can follow up. The more you complete, the faster your project goes into the club's records and onto the website.")
    ir=ip.add_run(intro); style_run(ir, italic=True, color=CHARCOAL)

    def pf(key): return prefill.get(key, "")

    section(doc,"Project Identity")
    field_table(doc, [
        (L("Project name"), pf("Project name")),
        (L("Rotary year", "e.g. 2024-25"), pf("Rotary year")),
        (L("Champion", "member who led it"), pf("Champion")),
    ])
    section(doc,"The Story")
    field_table(doc, [
        (L("What was it?", "one or two sentences"), pf("What was it?")),
        (L("Why did the club do it?", "the need it addressed"), pf("Why")),
        (L("Impact", "what changed — in human terms"), pf("Impact")),
    ])
    section(doc,"Classification")
    field_table(doc, [
        (L("Area of Focus", "Peace · Disease · Water · Maternal/Child · Education · Economy · Environment"), pf("Area of Focus")),
        (L("Funding", "Club · District Grant · Global Grant · Joint"), pf("Funding")),
        (L("Status", "Planning · Execution · Paused · Completed · Dropped"), pf("Status")),
    ])
    section(doc,"When & Where")
    field_table(doc, [
        (L("Start date", "e.g. 2024-09"), pf("Start date")),
        (L("Completion date", "blank if ongoing"), pf("Completion date")),
        (L("Location"), pf("Location")),
    ])
    section(doc,"By the Numbers")
    field_table(doc, [
        (L("Beneficiaries", "people helped"), pf("Beneficiaries")),
        (L("Project value (RM)"), pf("Value")),
        (L("Volunteer hours", "optional"), pf("Volunteer hours")),
    ])
    section(doc,"Partners")
    field_table(doc, [
        (L("Organisations / sponsors / co-clubs", "or “none”"), pf("Partners")),
    ])
    section(doc,"Extras  (all optional)")
    extras_last = L("Anything else?", "the club ran an earlier aquaponics installation at St Nicholas Home for the Blind in 2021-22 — was this related?") if draft_for else L("Anything else we should record?")
    field_table(doc, [
        (L("Photos?", "yes / no — where?"), ""),
        (L("Publicity", "links, write-ups"), ""),
        (L("Lessons learned / would you repeat it?"), ""),
        (extras_last, ""),
    ])
    # Footer thanks
    fp=doc.add_paragraph(); fp.paragraph_format.space_before=Pt(12)
    ft=fp.add_run(("Thank you, Mike. This completes the 2024-25 entry in the club's Service Projects record." if draft_for
                   else "Thank you. This goes into the club's Service Projects record and — once reviewed — the RC Georgetown website."))
    style_run(ft, italic=True, color=CHARCOAL, size=9.5)

    doc.save(path); print("wrote", path)

T="/Users/randaleastman/dev/clubs/apps/georgetown/docs/templates"
build(f"{T}/RC-Georgetown-Project-Summary-Form.docx")
build(f"{T}/Project-Summary-Aquaponics-Workshop-for-Mike.docx", draft_for="Mike Jackman",
      prefill={"Project name":"Aquaponics Workshop","Rotary year":"2024-25","Champion":"Mike Jackman",
               "Area of Focus":"Environment","Funding":"Club","Status":"Completed","Location":"Penang"})
