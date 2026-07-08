// Farben und Variablen
#let primary = rgb("#1a3a5f")
#let secondary = rgb("#2c5282")
#let accent = rgb("#319795")
#let light-bg = rgb("#f7fafc")
#let border-color = rgb("#e2e8f0")
#let code-bg = rgb("#edf2f7")

// Callout Funktion
#let callout(title: "Hinweis", body, color: secondary) = block(
  fill: light-bg,
  stroke: (left: 3pt + color),
  inset: 10pt,
  radius: (right: 4pt),
  width: 100%,
  above: 1em,
  below: 1em,
  [
    #text(weight: "bold", fill: color)[#title]\
    #v(2pt)
    #body
  ]
)

// Globale Layout-Regel (Template)
#let formelsammlung-layout(doc) = {
  set page(
    paper: "a4",
    margin: (x: 1.5cm, top: 1.5cm, bottom: 1.5cm),
    header: align(right, text(size: 8pt, fill: rgb("#718096"))[Klausur-Formelsammlung]),
    footer: [
      #set text(size: 8pt, fill: rgb("#718096"))
      #grid(
        columns: (1fr, 1fr),
        align(right, context counter(page).display("1 / 1", both: true))
      )
    ]
  )

  set text(font: "Liberation Sans", size: 9.5pt, fill: rgb("#2d3748"))
  set par(justify: true, leading: 0.65em)

  show heading.where(level: 1): it => block(
    width: 100%,
    stroke: (bottom: 2pt + primary),
    inset: (bottom: 0.5em),
    above: 2em, 
    below: 1em,
    text(size: 14pt, weight: "bold", fill: primary)[#it.body]
  )

  show heading.where(level: 2): it => block(
    width: 100%,
    stroke: (left: 4pt + secondary),
    inset: (left: 8pt),
    above: 1.5em, 
    below: 0.8em,
    text(size: 11pt, weight: "bold", fill: secondary)[#it.body]
  )

  show heading.where(level: 3): it => block(
    above: 1em, 
    below: 0.5em,
    text(size: 10pt, weight: "bold", style: "italic", fill: accent)[#it.body]
  )

  // Fügt den eigentlichen Inhalt in das Layout ein
  doc
}