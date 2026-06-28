#!/usr/bin/env python3
"""Build RC Georgetown Project Summary Word forms — matched to the house style
of RCG_Project_Brief / Approval FINAL templates (Calibri, azure header block,
thin grid, azure section bars, tick-boxes)."""
from docx import Document
from docx.shared import Pt, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

# ---- House palette (from FINAL templates) ----
AZURE    = "0067C8"
AZURE_DK = "005099"
GOLD     = "F7A81B"
LTBLUE   = "C8DCEE"
BODY     = "222222"
MUTED    = "777777"
GREY_BG  = "F5F5F5"
WHITE    = "FFFFFF"
BORDER   = "BFBFBF"   # thin grey grid (softer than pure black)
FONT     = "Calibri"

def _rgb(h): return RGBColor(int(h[0:2],16),int(h[2:4],16),int(h[4:6],16))

def el(tag, **attrs):
    e=OxmlElement(tag)
    for k,v in attrs.items(): e.set(qn(k.replace('_',':')), str(v))
    return e

def shade(cell, fill):
    cell._tc.get_or_add_tcPr().append(el('w:shd', w_val='clear', w_color='auto', w_fill=fill))

def borders(cell, color=BORDER, sz=4):
    tcPr=cell._tc.get_or_add_tcPr(); b=el('w:tcBorders')
    for edge in ('top','left','bottom','right'):
        b.append(el(f'w:{edge}', w_val='single', w_sz=sz, w_space='0', w_color=color))
    tcPr.append(b)

def margins(cell, t=70, b=70, l=110, r=110):
    tcPr=cell._tc.get_or_add_tcPr(); m=el('w:tcMar')
    for edge,val in (('top',t),('bottom',b),('left',l),('right',r)):
        m.append(el(f'w:{edge}', w_w=val, w_type='dxa'))
    tcPr.append(m)

def row_height(row, tw):
    row._tr.get_or_add_trPr().append(el('w:trHeight', w_val=tw, w_hRule='atLeast'))

def run(p, text, *, size=9.5, bold=False, italic=False, color=BODY, font=FONT):
    r=p.add_run(text); r.font.name=font; r.font.size=Pt(size); r.bold=bold; r.italic=italic; r.font.color.rgb=_rgb(color)
    rpr=r._element.get_or_add_rPr(); rf=rpr.find(qn('w:rFonts'))
    if rf is None: rf=el('w:rFonts'); rpr.insert(0,rf)
    for a in ('w:ascii','w:hAnsi','w:cs'): rf.set(qn(a),font)
    return r

def para(container, *, before=0, after=0, line=1.12, align=None):
    p=container.add_paragraph(); pf=p.paragraph_format
    pf.space_before=Pt(before); pf.space_after=Pt(after); pf.line_spacing=line
    if align: p.alignment=align
    return p

def cell_para(cell):
    p=cell.paragraphs[0]; p.paragraph_format.space_before=Pt(0); p.paragraph_format.space_after=Pt(0); p.paragraph_format.line_spacing=1.05
    cell.vertical_alignment=WD_ALIGN_VERTICAL.CENTER
    return p

# ---------- header block (azure bar) ----------
def header_block(doc, subtitle):
    t=doc.add_table(rows=1, cols=1); t.alignment=WD_TABLE_ALIGNMENT.LEFT; t.allow_autofit=False
    c=t.rows[0].cells[0]; c.width=Inches(6.7)
    shade(c, AZURE); borders(c, AZURE, 4); margins(c, t=90,b=90,l=160,r=160); row_height(t.rows[0], 900)
    p=cell_para(c)
    run(p,"ROTARY CLUB OF GEORGETOWN", size=11, bold=True, color=GOLD)
    p2=cell.add_paragraph() if False else c.add_paragraph(); p2.paragraph_format.space_before=Pt(2); p2.paragraph_format.space_after=Pt(0)
    run(p2,"Project Summary Form", size=18, bold=True, color=WHITE)
    p3=c.add_paragraph(); p3.paragraph_format.space_before=Pt(1); p3.paragraph_format.space_after=Pt(0)
    run(p3, subtitle, size=9, color=LTBLUE)
    para(doc, after=4)  # gap after header

# ---------- section bar ----------
def section(doc, title):
    t=doc.add_table(rows=1, cols=1); t.alignment=WD_TABLE_ALIGNMENT.LEFT; t.allow_autofit=False
    c=t.rows[0].cells[0]; c.width=Inches(6.7)
    shade(c, AZURE); borders(c, AZURE, 4); margins(c, t=40,b=40,l=110,r=110); row_height(t.rows[0], 300)
    p=cell_para(c); run(p, title, size=10.5, bold=True, color=WHITE)
    para(doc, after=0, before=0)  # tight gap; table spacing handles it

# ---------- field rows (label | answer) ----------
def fields(doc, rows, label_in=2.5, ans_in=4.2):
    t=doc.add_table(rows=0, cols=2); t.alignment=WD_TABLE_ALIGNMENT.LEFT; t.allow_autofit=False
    for label, hint, answer, tall in rows:
        r=t.add_row(); row_height(r, 620 if tall else 380)
        lc, ac = r.cells
        lc.width=Inches(label_in); ac.width=Inches(ans_in)
        shade(lc, GREY_BG)
        for c in (lc,ac): borders(c); margins(c)
        lp=cell_para(lc); run(lp, label, size=9.5, bold=True, color=BODY)
        if hint: run(lp, "  "+hint, size=8, italic=True, color=MUTED)
        ap=cell_para(ac)
        if answer: run(ap, answer, size=9.5, color=BODY)
    para(doc, after=6)  # space between sections

def F(label, answer="", hint=None, tall=False): return (label, hint, answer, tall)

def build(path, *, draft_for=None, prefill=None):
    pf=prefill or {}
    doc=Document()
    sec=doc.sections[0]
    sec.top_margin=Inches(0.7); sec.bottom_margin=Inches(0.7); sec.left_margin=Inches(0.9); sec.right_margin=Inches(0.9)
    st=doc.styles['Normal']; st.font.name=FONT; st.font.size=Pt(9.5); st.font.color.rgb=_rgb(BODY)

    subtitle = (f"{pf.get('Project name','')} — draft for {draft_for}" if draft_for
                else "Record of a club service project")
    header_block(doc, subtitle)

    intro = ("Hi Mike — we've pre-filled what we have on record. Please correct anything wrong and type your "
             "answers into the blank right-hand cells. Thank you!" if draft_for else
             "Type your answers directly into the right-hand cells. Blanks are fine; we can follow up.")
    ip=para(doc, after=8); run(ip, intro, size=9, italic=True, color="555555")

    g=lambda k: pf.get(k,"")

    section(doc,"Project Identity")
    fields(doc, [
        F("Project name", g("Project name")),
        F("Rotary year", g("Rotary year"), "e.g. 2024-25"),
        F("Champion", g("Champion"), "member who led it"),
    ])
    section(doc,"The Story")
    fields(doc, [
        F("What was it?", g("What was it?"), "one or two sentences", tall=True),
        F("Why did the club do it?", g("Why"), "the need it addressed", tall=True),
        F("Impact", g("Impact"), "what changed — in human terms", tall=True),
    ])
    section(doc,"Classification")
    fields(doc, [
        F("Area of Focus", g("Area of Focus"), "Peace · Disease · Water · Maternal/Child · Education · Economy · Environment"),
        F("Funding", g("Funding"), "Club · District Grant · Global Grant · Joint"),
        F("Status", g("Status"), "Planning · Execution · Paused · Completed · Dropped"),
    ])
    section(doc,"When & Where")
    fields(doc, [
        F("Start date", g("Start date"), "e.g. 2024-09"),
        F("Completion date", g("Completion date"), "blank if ongoing"),
        F("Location", g("Location")),
    ])
    section(doc,"By the Numbers")
    fields(doc, [
        F("Beneficiaries", g("Beneficiaries"), "people helped"),
        F("Project value (RM)", g("Value")),
        F("Volunteer hours", g("Volunteer hours"), "optional"),
    ])
    section(doc,"Partners")
    fields(doc, [
        F("Organisations / sponsors / co-clubs", g("Partners"), "or “none”", tall=True),
    ])
    section(doc,"Extras  (all optional)")
    last_hint = ("the club ran an earlier aquaponics installation at St Nicholas Home for the Blind in 2021-22 — was this related?"
                 if draft_for else None)
    fields(doc, [
        F("Photos?", "", "yes / no — where?"),
        F("Publicity", "", "links, write-ups"),
        F("Lessons learned / would you repeat it?", "", None, tall=True),
        F("Anything else we should record?", "", last_hint, tall=True),
    ])
    fp=para(doc, before=10)
    run(fp, ("Thank you, Mike. This completes the 2024-25 entry in the club's Service Projects record."
             if draft_for else
             "Thank you. This goes into the club's Service Projects record and — once reviewed — the RC Georgetown website."),
        size=8.5, italic=True, color=MUTED)
    doc.save(path); print("wrote", path)

T="/Users/randaleastman/dev/clubs/apps/georgetown/docs/templates"
build(f"{T}/RC-Georgetown-Project-Summary-Form.docx")
build(f"{T}/Project-Summary-Aquaponics-Workshop-for-Mike.docx", draft_for="Mike Jackman",
      prefill={"Project name":"Aquaponics Workshop","Rotary year":"2024-25","Champion":"Mike Jackman",
               "Area of Focus":"Environment","Funding":"Club","Status":"Completed","Location":"Penang"})
