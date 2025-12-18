# Technical Briefing: AI-Generated Image Style System for HuaQiao Projects

**To**: COO
**From**: CTO
**Date**: 2025-12-18
**Subject**: Proposed Visual Style Framework for HuaQiao Foundation, Bridge, Rotary & Toastmasters Applications

---

## Executive Summary

We're developing a unified AI-generated image style system for all HuaQiao-related projects (Foundation, Bridge, Rotary Club app, Toastmasters app) that is:

- **Sophisticated but approachable** - Professional quality for business leaders, not stuffy or corporate
- **Optimistic and soothing** - Reflects our mission of service and global connection
- **Colorblind-friendly** - Accessible to 8-10% of male population with color vision deficiency
- **Globally appropriate** - Multicultural audience without cultural stereotypes
- **AI-reproducible** - Consistent quality using ChatGPT/DALL-E with phrase-block-structure prompts

This briefing explains the **5 proposed visual styles**, the **color strategy**, and the **technical approach** behind the test prompts.

---

## Context: Why We Need This

**Current State**:
- Multiple HuaQiao projects launching (Foundation, Bridge, Rotary app, Toastmasters app)
- Need consistent visual identity across all properties
- Stock photography feels generic and doesn't represent our global community authentically
- Budget/timeline constraints favor AI-generated imagery over custom illustration

**Requirements**:
- Reflects thoughtful, globally-minded business professionals
- Not cartoony or overly playful (our audience: Rotarians, senior professionals, foundation donors)
- Colorblind-safe (critical for accessibility)
- Minimalist aesthetic (clean, modern, not cluttered)
- Works across different service project types and cultural contexts

---

## Strategic Color Approach

### Primary Palette Source: Rotary International Official Colors

We're anchoring the visual system to **Rotary's official brand colors** because:

1. **Brand Compliance** - Georgetown Rotary app must follow Rotary International guidelines
2. **Color Psychology Alignment** - Rotary's palette already conveys trust (blues), optimism (gold), and action (orange/turquoise)
3. **Accessibility Built-In** - Rotary provides colorblind-safe colors across their Areas of Focus
4. **Cross-Project Continuity** - Using same palette creates visual family across HuaQiao projects

### Colorblind-Safe Subset (Used in All Prompts)

| Color | Hex | Usage | Colorblind Safe? |
|-------|-----|-------|------------------|
| **Sky Blue** | `#00A2E0` | Water/hygiene projects, primary service color | ✅ Yes |
| **Azure Blue** | `#0067C8` | Community/connection, primary brand color | ✅ Yes |
| **Rotary Gold** | `#F7A81B` | Hope/transformation, accent/highlight | ✅ Yes |
| **Turquoise** | `#00ADBB` | Economic development, sustainable progress | ✅ Yes |
| **Cardinal Red** | `#E02927` | Health/disease prevention | ✅ Yes |
| **Orange** | `#FF7600` | Education/literacy | ✅ Yes |

**Avoided in Critical UI**:
- ❌ Violet `#901F93` (maternal health) - problematic for deuteranopia
- ❌ Grass Green `#009739` (environment) - problematic for red-green colorblindness

### Color Usage Strategy in Prompts

**3-4 color limit per image**:
- Primary color from Area of Focus (e.g., Sky Blue for water projects)
- Supporting color for community/connection (Azure Blue)
- Accent color for optimism (Gold)
- Optional 4th color for specific thematic emphasis

**Why this matters**:
- Too many colors = visual clutter, confusing message
- Colorblind users can't distinguish certain color combinations
- Consistent palette = brand recognition across projects

---

## Five Proposed Visual Styles

Each style was tested with **two scenarios**:
1. **Generic service project** (broad testing)
2. **Specific project: Rural Asian village well** (cultural sensitivity testing)

### Style A: Soft Geometric Minimalism

**Visual Characteristics**:
- Clean geometric shapes (circles, arcs, rounded rectangles)
- Subtle gradients (not flat, not complex)
- Generous white space
- Soft drop shadows for depth

**Aesthetic Reference**: Apple keynote slides, Scandinavian design, modern tech companies

**Mood**: Calm, professional, contemporary

**Best For**:
- Corporate-facing content (Foundation donor communications)
- Professional presentations
- Desktop/web hero images
- Audiences preferring "clean tech" aesthetic

**Technical Advantages**:
- Simple shapes = reliable AI generation
- Clear hierarchy = works at small sizes (mobile)
- Professional without being cold

**Potential Concerns**:
- May feel too corporate/sterile for some audiences
- Less warmth than textured approaches

---

### Style B: Layered Translucent Forms

**Visual Characteristics**:
- Overlapping translucent shapes (40-70% opacity)
- Shapes blend where they intersect (creates new colors)
- Organic forms (circles, ovals, flowing curves)
- Sense of connection and collaboration

**Aesthetic Reference**: Notion illustrations, modern infographics, Google Material Design

**Mood**: Collaborative, interconnected, hopeful

**Best For**:
- Content emphasizing partnership (Bridge app)
- Multi-stakeholder projects
- Illustrating overlapping impact areas
- Younger/more contemporary audiences

**Technical Advantages**:
- Transparency conveys "working together" metaphorically
- Color blending creates visual interest without adding elements
- Soft, approachable feel

**Potential Concerns**:
- Complexity may reduce at very small sizes
- Transparency effect requires precise AI prompt adherence

---

### Style C: Refined Line Art with Color Fields

**Visual Characteristics**:
- Simple continuous line drawings (hands, abstract concepts)
- Paired with solid geometric color blocks
- Balance of illustration and abstraction
- Editorial quality (not decorative)

**Aesthetic Reference**: Financial Times illustrations, LinkedIn editorial graphics, The Economist

**Mood**: Thoughtful, human-centered, professional

**Best For**:
- Long-form content (articles, reports)
- Content emphasizing human impact
- Print materials (high contrast)
- Audiences expecting editorial sophistication

**Technical Advantages**:
- Line art + color blocks = high contrast (accessibility)
- Editorial style = credibility for serious topics
- Human element (hands) without photorealism

**Potential Concerns**:
- Line art quality varies with AI generation (may need iteration)
- More complex to prompt consistently

---

### Style D: Atmospheric Gradients with Simple Icons

**Visual Characteristics**:
- Smooth 2-color gradients filling entire frame
- Very simple icon/symbol overlay (solid or outlined)
- Lots of breathing room
- Modern, clean aesthetic

**Aesthetic Reference**: Stripe product pages, modern SaaS branding, tech startups

**Mood**: Serene, forward-looking, inclusive

**Best For**:
- App splash screens/loading states
- Social media graphics (Instagram, LinkedIn)
- Mobile-first content
- Younger, tech-forward audiences

**Technical Advantages**:
- Simplest to generate reliably
- Works at any size (mobile to billboard)
- Fast visual recognition

**Potential Concerns**:
- May feel too generic/tech-startup
- Less storytelling depth than other styles
- Gradient trends shift quickly

---

### Style E: Textured Minimalism (Brandmine-Inspired)

**Visual Characteristics**:
- Soft paper grain texture throughout
- Abstract symbolic forms (not literal)
- Conceptual rather than illustrative
- Warm, editorial magazine quality

**Aesthetic Reference**: Monocle magazine, Kinfolk editorial style, premium lifestyle brands

**Mood**: Sophisticated, globally-minded, authentic

**Best For**:
- Premium content (Foundation annual reports)
- Storytelling/narrative content
- Audiences valuing craftsmanship and thoughtfulness
- Cross-cultural content requiring sophistication

**Technical Advantages**:
- Textured grain = premium, crafted feel
- Conceptual approach = culturally neutral
- Aligns with your existing Brandmine aesthetic
- Most editorial/magazine quality

**Potential Concerns**:
- Texture may reduce legibility at very small sizes
- Requires most prompt precision to maintain quality

---

## Technical Implementation: Phrase Block Structure (PBS)

### What Is PBS?

**Traditional AI prompt**:
> "Create a beautiful editorial-style image showing community water access with soft textures, abstract forms, and warm colors, but without any text."

**Phrase Block Structure**:
```
SUBJECT:
service project: fresh water well for rural village
area of focus: water, sanitation & hygiene

STYLE:
textured minimalism, soft paper-grain texture
editorial quality, sophisticated

PALETTE:
#00A2E0 (sky blue - water)
#0067C8 (azure blue - community)
#F7A81B (gold - hope)

VISUAL ELEMENTS:
overlapping circles suggesting water ripples
soft arc forms implying well structure

CONSTRAINTS:
no text, no logos, no photorealism
colorblind-safe palette only
```

### Why PBS Matters

**Modern AI image models (ChatGPT/DALL-E, Midjourney, Stable Diffusion) work better with PBS because**:

1. **Token-by-token processing** - Short phrases carry more weight than long sentences
2. **Unambiguous instructions** - Removes narrative fluff that models misinterpret
3. **Consistent vocabulary** - Repeating same style words = unified visual system
4. **Hard constraints** - "No text, no logos" more reliable when isolated in CONSTRAINTS block
5. **Batch consistency** - PBS prompts generate more similar results across multiple images

**Business Impact**:
- **Time savings**: Less iteration to get desired result
- **Quality consistency**: 100 images look like they're from same design system
- **Handoff clarity**: New team members can modify prompts without design expertise

---

## Color Psychology & Cultural Considerations

### Why These Colors Work Globally

**Blue Family (Azure, Sky Blue, Turquoise)**:
- **Universal positive associations**: Trust, calm, water, sky, stability
- **Cross-cultural consistency**: Preferred color in most cultures worldwide
- **Gender-neutral**: No masculine/feminine skew in most markets
- **Professional credibility**: Dominant in corporate/finance/healthcare branding

**Gold/Amber**:
- **Warmth without cultural baggage**: Unlike red (danger in West, luck in China), gold reads as optimistic globally
- **Accessibility**: High contrast against blues
- **Premium feel**: Suggests quality and value

**Orange**:
- **Energy without aggression**: Warmer than red, more energetic than yellow
- **Education associations**: Creativity, learning, youth
- **Colorblind-safe**: Distinguishable from blues/greens

### Cultural Sensitivity in Visual Elements

**What We Avoid**:
- ❌ Literal cultural motifs (patterns, architecture, traditional symbols)
- ❌ Ethnically-specific imagery (facial features, traditional dress)
- ❌ Geographic stereotypes (bamboo for Asia, pyramids for Egypt)
- ❌ Poverty imagery (focusing on need vs. agency)

**What We Emphasize**:
- ✅ Universal symbols (water, hands, circles, growth)
- ✅ Abstract/conceptual representation
- ✅ Agency and action (not passive recipients)
- ✅ Collaboration (overlapping forms, connection)
- ✅ Optimism (upward movement, light, hope)

**Example from Well Project Prompts**:
- **Instead of**: Literal Asian village imagery (rice paddies, traditional buildings, ethnic faces)
- **We use**: Abstract water ripples, universal hand gestures, geometric well forms
- **Result**: Globally appropriate image that doesn't tokenize or stereotype

---

## Accessibility Considerations

### Colorblind-Safe Palette (Core Requirement)

**8-10% of males have color vision deficiency**, most commonly:
- **Deuteranopia** (green-weak, 5% of males)
- **Protanopia** (red-weak, 2.5% of males)

**Our Strategy**:
1. **Primary UI colors**: Only use colorblind-safe subset (Blues, Gold, Orange, Turquoise, Cardinal)
2. **Avoid problematic combos**: Never red-green or blue-violet for critical information
3. **Contrast over color**: Use lightness differences, not just hue
4. **Icons + color**: Never rely on color alone for meaning

**Testing Protocol**:
- All images checked with colorblind simulators (Coblis, Color Oracle)
- Navigation/CTAs work in grayscale
- Text overlays meet WCAG 2.1 AA contrast ratios (4.5:1 minimum)

### Mobile-First Image Requirements

**Georgetown Rotary app usage context**:
- 70%+ usage during meetings (mobile phones)
- Often one-handed operation
- Variable lighting conditions (meeting rooms)

**Image Design Implications**:
- **Simple forms**: 2-4 elements max (readable at 320px width)
- **High contrast**: Works in bright meeting rooms and dim restaurants
- **Negative space**: Text overlays don't obscure key visual elements
- **Scalable concepts**: Same image works hero-size (1536px) and thumbnail (200px)

---

## Recommended Testing Protocol

### Phase 1: Style Selection (This Week)

**COO Action**:
1. Review 5 styles using provided ChatGPT prompts
2. Generate test images for each style (rural Asian village well project)
3. Evaluate against criteria:
   - Sophisticated enough for donor/professional audience?
   - Optimistic and soothing mood?
   - Appropriate for multicultural contexts?
   - Aligns with HuaQiao Foundation brand values?

**Output**: Select 2 finalist styles for deeper testing

### Phase 2: Style Refinement (Next Week)

**CTO + COO**:
1. Generate 10 images in each finalist style across different scenarios:
   - Different Areas of Focus (water, health, education, peace)
   - Different project scales (local, regional, global)
   - Different tones (celebratory, reflective, urgent)
2. Test colorblind accessibility (Coblis simulator)
3. Test at different sizes (mobile 320px → desktop 1920px)

**Output**: Select 1 primary style for HuaQiao visual system

### Phase 3: Style Guide Documentation (Week After)

**CTO**:
1. Document chosen style with prompt templates
2. Create batch generation workflows
3. Build asset library (50 images across common project types)
4. Write guidelines for team image creation

**Output**: HuaQiao Visual Style Guide (similar to Brandmine's system)

---

## Business Impact & ROI

### Cost Savings
- **Traditional approach**: Custom illustration at $500-2000/image
- **Stock photography**: $50-200/image + licensing restrictions
- **AI-generated (our approach)**: $0.10-0.50/image + unlimited usage rights
- **Estimated annual savings**: $10,000-25,000 across all HuaQiao projects

### Time Efficiency
- **Traditional design**: 3-5 days per image (brief → concept → revision → final)
- **AI with PBS prompts**: 15-30 minutes per image (including iteration)
- **Result**: 100x faster turnaround for visual assets

### Brand Consistency
- **Problem**: Different designers = visual inconsistency
- **Solution**: PBS prompt templates = anyone can generate on-brand images
- **Result**: Unified visual identity across 4+ HuaQiao properties

### Accessibility Compliance
- **Requirement**: WCAG 2.1 AA for government/nonprofit grant eligibility
- **Our approach**: Colorblind-safe palette built into prompts
- **Result**: Compliance by default, no retrofitting needed

---

## Risks & Mitigations

### Risk 1: AI-Generated Images Look "AI-Generated"

**Concern**: Generic, soulless, or obviously artificial aesthetic

**Mitigation**:
- PBS prompts emphasize "editorial quality" and "sophisticated"
- Textured styles (E) add crafted feel
- Human review before publication
- Iterate prompts until quality matches manual design

**Fallback**: If AI quality insufficient, hybrid approach (AI draft → human designer refinement)

---

### Risk 2: Cultural Insensitivity

**Concern**: AI models trained on Western-dominant datasets may produce culturally inappropriate imagery

**Mitigation**:
- Abstract/conceptual approach (not literal cultural representation)
- COO review (cultural expertise) before publication
- Community feedback loops (test with Rotary members from different regions)
- Explicit PBS constraints: "no cultural stereotypes, globally appropriate"

**Escalation**: Any culturally questionable image discarded immediately

---

### Risk 3: Accessibility Failures

**Concern**: Colorblind users can't distinguish key elements

**Mitigation**:
- Colorblind-safe palette hardcoded into all prompts
- Every image tested with Coblis simulator
- Text overlays checked for contrast (WebAIM tool)
- Icons never rely on color alone

**Success Metric**: 100% of images pass colorblind simulation testing

---

### Risk 4: Prompt Drift Over Time

**Concern**: As team members create new images, visual consistency degrades

**Mitigation**:
- PBS prompt templates locked in style guide
- Required fields (PALETTE, CONSTRAINTS) prevent improvisation
- Quarterly visual audit (CTO reviews all new images)
- Batch generation encouraged (10 images at once = more consistent)

**Governance**: Only CTO can modify core PBS templates

---

## Open Questions for COO

1. **Style Preference**: Which of the 5 styles best reflects HuaQiao Foundation brand values?
   - **A**: Corporate/clean (Soft Geometric)
   - **B**: Collaborative/connected (Layered Translucent)
   - **C**: Editorial/thoughtful (Line Art + Color)
   - **D**: Modern/tech-forward (Atmospheric Gradients)
   - **E**: Premium/sophisticated (Textured Minimalism)

2. **Mood Calibration**: How optimistic vs. serious should imagery feel?
   - Service projects require gravitas (water access is life-or-death)
   - But we want to inspire action, not depress viewers
   - Where's the right balance for HuaQiao brand?

3. **Cultural Authority**: Who reviews images for cultural appropriateness?
   - COO as primary reviewer?
   - Advisory committee?
   - Regional Rotary club feedback?

4. **Timeline**: When do we need finalized visual system?
   - Foundation website launch date?
   - Rotary app beta release?
   - Coordinating with other HuaQiao project milestones?

5. **Scope**: Should this visual system extend beyond service project imagery?
   - Hero images for website pages?
   - Social media templates?
   - Presentation decks?
   - Print materials (annual reports)?

---

## Next Steps

**Immediate (This Week)**:
1. COO tests 5 styles using provided ChatGPT prompts
2. COO shares top 2 style preferences with CTO
3. Schedule 30-min sync to discuss open questions

**Short-term (Next 2 Weeks)**:
1. Refine finalist styles with expanded testing
2. Conduct colorblind accessibility testing
3. Select primary style for HuaQiao system
4. Begin style guide documentation

**Medium-term (Next Month)**:
1. Generate asset library (50 images)
2. Train team on PBS prompt usage
3. Deploy in Georgetown Rotary app beta
4. Gather user feedback

---

## Appendix: Technical Details

### Colorblind Simulation Tools
- **Coblis**: https://www.color-blindness.com/coblis-color-blindness-simulator/
- **Color Oracle**: Free desktop app for Mac/Windows/Linux
- **Chrome DevTools**: Built-in vision deficiency emulator

### WCAG Contrast Requirements
- **Normal text**: 4.5:1 minimum contrast ratio
- **Large text (18pt+)**: 3:1 minimum contrast ratio
- **Tool**: WebAIM Contrast Checker (https://webaim.org/resources/contrastchecker/)

### AI Image Generation Platforms
- **Primary**: ChatGPT with DALL-E 3 (integrated, easy prompting)
- **Alternative**: Midjourney (higher artistic quality, steeper learning curve)
- **Backup**: Stable Diffusion (open source, requires technical setup)

### Rotary Brand Resources
- **Rotary Brand Center**: https://brandcenter.rotary.org
- **Areas of Focus Icons**: Available for download from Brand Center
- **Color Guidelines**: `apps/georgetown/public/brand/rotary-colors.json`
- **Typography**: Open Sans (self-hosted, no external CDN)

---

**End of Briefing**

*Questions or feedback? Please schedule time with CTO to discuss.*
