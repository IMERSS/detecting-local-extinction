---
title: Per-cell extirpation
math: true
weight: 3
---

<p>We want to estimate how likely it is that a species has disappeared from a specific cell. To do this, we combine two sources of information:</p>

<ul>
  <li>How likely extinction seemed before getting new data (the prior estimate).</li>
  <li>How much effort we spent searching the cell without finding the species (more search with no sightings makes extinction more likely).</li>
</ul>

<p>Each source is given a weight to show how strongly it should influence the result. We then turn these into two numbers, \( \alpha \) and \( \beta \), which form a beta distribution. This distribution represents both our estimate of the extinction probability and how uncertain that estimate is.</p>

<ul>
  <li>\( \alpha \) increases when earlier evidence suggested extinction.</li>
  <li>\( \beta \) increases when earlier evidence suggested the species was still present, or when we searched extensively and still found nothing.</li>
</ul>

<p>In plain terms, the calculation blends what we believed beforehand with what we learned from searching, producing a refined probability estimate expressed as a distribution rather than a single number.</p>

<p>
  <a class="btn btn-primary" data-bs-toggle="collapse" href="#collapseExample" role="button" aria-expanded="false" aria-controls="collapseExample">
    Expand for mathematical details
  </a>
</p>
<div class="collapse" id="collapseExample">
  <div class="card card-body">



<p>Given a search effort \(S_t\) in a particular cell, we apply
our weighted search effort \(S_t W_s\) and weighted prior extirpation estimate
\(P_r W_p\) to derive our formula for the per-cell posterior parameters \(  (\alpha_t, \beta_t) \)
for the beta distribution that we assign to the extirpation likelihood in that cell. This appears
in the Methods S7 section of the paper's supporting information:<p>

<div style="display: flex;justify-content: center;">
\(  (\alpha_t, \beta_t) = (P_r W_p, (1 - P_r) W_p + S_t W_s)  \)
</div>

</div>
</div>
