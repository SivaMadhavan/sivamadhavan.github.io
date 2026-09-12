+++
title = "How Large Language Models (LLMs) Actually Work: An Interactive Guide"
date = '2026-09-12T20:10:00+05:30'
draft = false
author = "Siva"
description = "A deep, intuitive, and interactive visual breakdown of modern Large Language Models — from tokenization and embeddings to self-attention, logits, and temperature sampling."
tags = ["AI", "LLM", "Deep Learning", "Transformers", "Machine Learning"]
categories = ["Tech", "Artificial Intelligence"]
showToc = true
TocOpen = true
+++

Large Language Models (LLMs) like GPT-4, Claude, and LLaMA appear to understand reasoning, humor, code, and nuance. Yet under the hood, every LLM operates on a single core objective: **given a sequence of tokens, predict the probability distribution for the very next token**.

In this guide, we demystify how LLMs transform human language into math, process context through the Transformer architecture, and generate coherent text. You can interact with the live demos below to see the math in action.

---

## 1. Step One: Tokenization

Computers cannot process raw characters or words directly. Before text enters a neural network, it is split into chunks called **tokens** using algorithms like **Byte-Pair Encoding (BPE)** or **WordPiece**.

A token can be an entire word, a subword, a punctuation mark, or even a single byte. On average in English, 1 token is roughly 4 characters or 0.75 words.

### 🎮 Interactive Tokenizer Simulator

Type any sentence below to see how an LLM breaks it down into discrete tokens:

<div class="interactive-card" id="tokenizer-card">
  <div class="card-header">
    <span class="card-badge">LIVE DEMO 1</span>
    <h4>Byte-Pair Tokenizer Breakdown</h4>
  </div>
  <div class="card-body">
    <div class="input-group">
      <label for="tok-input">Enter text to tokenize:</label>
      <input type="text" id="tok-input" value="Transformers and LLMs predict the next token with self-attention." />
      <div class="quick-chips">
        <span>Try:</span>
        <button class="chip-btn" onclick="setTokenText('Attention is all you need.')">Attention is all you need.</button>
        <button class="chip-btn" onclick="setTokenText('Indivisibility and extraterrestrial 12345')">Subword edge-cases</button>
        <button class="chip-btn" onclick="setTokenText('def predict_next(tokens): return max(logits)')">Code snippet</button>
      </div>
    </div>
    <div class="token-results">
      <div class="token-stats">
        <span>Tokens: <strong id="token-count">0</strong></span>
        <span>Characters: <strong id="char-count">0</strong></span>
        <span>Avg chars/token: <strong id="ratio-count">0</strong></span>
      </div>
      <div id="token-display" class="token-grid"></div>
    </div>
  </div>
</div>

Once tokenized, each token is mapped to a unique integer ID from a fixed vocabulary (typically between 32,000 and 128,000 distinct tokens).

---

## 2. From Token IDs to Vector Embeddings

An integer ID like `4215` conveys no geometric meaning to a neural network. To capture semantic relationships, the model maps each token ID into a high-dimensional vector space called an **Embedding Vector**:

$$\vec{e} \in \mathbb{R}^{d_{\text{model}}}$$

In models like LLaMA-3 (70B), $d_{\text{model}} = 8192$. In this space:
- Similar concepts point in similar directions (e.g., $\vec{\text{king}} - \vec{\text{man}} + \vec{\text{woman}} \approx \vec{\text{queen}}$).
- Words with multiple meanings get positioned in rich semantic sub-spaces.

### Positional Encoding
Because Transformers process all tokens simultaneously (unlike older sequential RNNs), the model needs to know **where** each word appears in the sentence. We add **Positional Embeddings** (such as Sinusoidal encodings or RoPE — *Rotary Position Embeddings*) directly to the token embeddings:

$$\vec{x}_i = \vec{e}_i + \vec{p}_i$$

---

## 3. The Engine Room: Multi-Head Self-Attention

Self-attention allows the model to connect different words in a sentence, resolving pronouns, ambiguity, and long-range dependencies.

When reading the word **"it"** in:
> *"The animal didn't cross the street because **it** was too tired."*

The self-attention mechanism computes high affinity between **"it"** and **"animal"**. If the sentence ended with *"it was too wide"*, the attention would shift to **"street"**.

### The Query, Key, and Value ($Q, K, V$) Formulation

For each token vector, the model creates three distinct vectors by multiplying with learned weight matrices:
1. **Query ($Q$)**: *"What am I looking for?"*
2. **Key ($K$)**: *"What kind of information do I offer?"*
3. **Value ($V$)**: *"What is my actual content?"*

The attention score between query $i$ and key $j$ is calculated via dot product:

$$\text{Attention}(Q, K, V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V$$

### 🎮 Interactive Attention Matrix Explorer

Click any word below to see which other words it pays attention to in the context:

<div class="interactive-card" id="attention-card">
  <div class="card-header">
    <span class="card-badge">LIVE DEMO 2</span>
    <h4>Self-Attention Weight Visualizer</h4>
  </div>
  <div class="card-body">
    <p class="desc">Select a query token to inspect its attention weights across the context:</p>
    <div id="sentence-tokens" class="interactive-tokens-row"></div>
    <div class="attention-viz-container">
      <div id="attention-details">
        <div class="active-query-label">Active Query: <span id="current-query-word" class="highlight-word">"it"</span></div>
        <div id="attention-bars" class="attention-bars"></div>
      </div>
    </div>
  </div>
</div>

---

## 4. Inside the Transformer Layer

A single Transformer block consists of two primary modules:
1. **Multi-Head Self-Attention (MHA)**: Lets tokens exchange information across the entire sequence.
2. **Feed-Forward Network (FFN / MLP)**: Allows each token to process and retrieve factual knowledge stored within the model's weights.

Surrounding each module are two critical architectural innovations:
- **Residual (Skip) Connections**: $\vec{x}_{\text{out}} = \vec{x} + \text{SubLayer}(\vec{x})$. This prevents gradients from vanishing during backpropagation across dozens of layers.
- **Layer Normalization (RMSNorm)**: Stabilizes activations across features.

Modern LLMs stack dozens of these identical layers (e.g. 32 layers for a 7B model, 80+ layers for 70B+ models).

---

## 5. From Logits to Next Token: Sampling & Temperature

After passing through all Transformer layers, the final vector is projected onto the vocabulary dimension via the language modeling head (an unembedding matrix). This produces raw numerical scores called **Logits** ($z_1, z_2, \dots, z_V$).

To convert logits into a probability distribution, we apply the **Softmax function with Temperature ($T$)**:

$$P(w_i) = \frac{\exp(z_i / T)}{\sum_{j} \exp(z_j / T)}$$

### How Temperature Shapes Creativity
- **Low Temperature ($T \to 0$)**: Sharpens the distribution. The highest logit dominates. Responses become deterministic, precise, and repetitive.
- **High Temperature ($T > 1.0$)**: Flattens the distribution. Lower-probability tokens have a higher chance of being picked. Responses become diverse, creative, or chaotic.
- **Top-$p$ (Nucleus Sampling)**: Selects only the smallest set of tokens whose cumulative probability exceeds threshold $p$.

### 🎮 Interactive Next-Token Probability Simulator

Adjust the Temperature and Top-$p$ sliders below in real time to observe how the candidate probability distribution shifts:

<div class="interactive-card" id="sampling-card">
  <div class="card-header">
    <span class="card-badge">LIVE DEMO 3</span>
    <h4>Logits, Softmax & Temperature Playground</h4>
  </div>
  <div class="card-body">
    <div class="prompt-box">
      <span class="prompt-prefix">Context Prompt:</span>
      <span class="prompt-text" id="sim-prompt">The future of artificial intelligence will revolutionize</span>
      <span class="prompt-next">[next token?]</span>
    </div>

    <div class="controls-row">
      <div class="control-col">
        <div class="slider-label">
          <span>Temperature ($T$): <strong id="temp-val">0.70</strong></span>
          <span class="tip" id="temp-desc">Balanced & Fluent</span>
        </div>
        <input type="range" id="temp-slider" min="0.05" max="1.8" step="0.05" value="0.70" oninput="updateSamplingSim()" />
      </div>
      <div class="control-col">
        <div class="slider-label">
          <span>Top-P (Nucleus): <strong id="topp-val">0.90</strong></span>
          <span class="tip">Cumulative probability cutoff</span>
        </div>
        <input type="range" id="topp-slider" min="0.1" max="1.0" step="0.05" value="0.90" oninput="updateSamplingSim()" />
      </div>
    </div>

    <div class="distribution-view">
      <div class="dist-header">
        <span>Candidate Token</span>
        <span>Raw Logit</span>
        <span>Probability</span>
      </div>
      <div id="candidates-container"></div>
    </div>

    <div class="sampling-actions">
      <button class="action-btn" onclick="sampleAndAppendToken()">🎲 Sample &amp; Append Next Token</button>
      <button class="action-btn secondary" onclick="resetSamplingPrompt()">↺ Reset Prompt</button>
    </div>
  </div>
</div>

---

## 6. How Are LLMs Trained?

Training modern foundation models happens in three distinct phases:

| Stage | Data Source | Objective | Outcome |
| :--- | :--- | :--- | :--- |
| **1. Pre-Training** | Trillions of web tokens, books, code, papers | Self-supervised next-token prediction | Base model with general world knowledge, but raw & unaligned |
| **2. Supervised Fine-Tuning (SFT)** | Hundreds of thousands of curated Q&A / dialog pairs | Instruction following & chat style | Helpful conversational assistant |
| **3. Alignment (RLHF / DPO)** | Human feedback & preference rankings | Optimize for truthfulness, safety, and helpfulness | Calibrated, safe model ready for deployment |

---

## Key Takeaways

1. **Tokens, not words**: Text is divided into subword tokens and mapped into high-dimensional geometric embedding vectors.
2. **Self-Attention is relational**: It allows tokens to dynamic route contextual information regardless of distance.
3. **Generative auto-regression**: Text generation is an iterative loop where each newly sampled token is appended to the input context to predict the next one.
4. **Sampling parameters control behavior**: Temperature and Top-$p$ steer the trade-off between deterministic precision and exploratory creativity.

---

<style>
/* Embedded Interactive Styles */
.interactive-card {
  background: var(--entry);
  border: 1px solid var(--border);
  border-radius: 10px;
  margin: 1.8rem 0;
  overflow: hidden;
  box-shadow: 0 4px 18px rgba(0,0,0,0.06);
}
.card-header {
  display: flex;
  align-items: center;
  gap: 0.8rem;
  padding: 0.8rem 1.2rem;
  background: rgba(125, 125, 125, 0.08);
  border-bottom: 1px solid var(--border);
}
.card-badge {
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  background: var(--primary);
  color: var(--theme);
  padding: 0.15rem 0.5rem;
  border-radius: 4px;
}
.card-header h4 {
  margin: 0;
  font-size: 0.95rem;
  font-weight: 600;
}
.card-body {
  padding: 1.2rem;
}
.input-group label {
  display: block;
  font-size: 0.82rem;
  font-weight: 600;
  margin-bottom: 0.4rem;
  color: var(--secondary);
}
.input-group input[type="text"] {
  width: 100%;
  padding: 0.6rem 0.8rem;
  border-radius: 6px;
  border: 1px solid var(--border);
  background: var(--theme);
  color: var(--primary);
  font-size: 0.88rem;
  font-family: inherit;
  outline: none;
  box-sizing: border-box;
}
.input-group input[type="text"]:focus {
  border-color: #47F5B4;
}
.quick-chips {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.4rem;
  margin-top: 0.5rem;
  font-size: 0.76rem;
  color: var(--secondary);
}
.chip-btn {
  background: rgba(125, 125, 125, 0.12);
  border: 1px solid var(--border);
  color: var(--primary);
  border-radius: 12px;
  padding: 0.2rem 0.55rem;
  font-size: 0.72rem;
  cursor: pointer;
  transition: all 0.15s ease;
}
.chip-btn:hover {
  background: #47F5B4;
  color: #0B0F0D;
  border-color: #47F5B4;
}
.token-results {
  margin-top: 1rem;
}
.token-stats {
  display: flex;
  gap: 1.2rem;
  font-size: 0.78rem;
  color: var(--secondary);
  margin-bottom: 0.6rem;
}
.token-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  min-height: 48px;
  padding: 0.6rem;
  border-radius: 6px;
  background: var(--theme);
  border: 1px dashed var(--border);
}
.token-badge {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  padding: 0.2rem 0.45rem;
  border-radius: 4px;
  font-size: 0.82rem;
  font-family: monospace;
  font-weight: 500;
  border: 1px solid rgba(0,0,0,0.1);
  animation: fadeIn 0.2s ease;
}
.token-id {
  font-size: 0.6rem;
  opacity: 0.65;
  margin-top: 0.1rem;
}

/* Attention styles */
.interactive-tokens-row {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  margin: 0.8rem 0;
}
.attn-word {
  padding: 0.4rem 0.7rem;
  border-radius: 6px;
  border: 1px solid var(--border);
  background: var(--theme);
  cursor: pointer;
  font-size: 0.84rem;
  font-weight: 500;
  transition: all 0.2s ease;
}
.attn-word:hover {
  border-color: #47F5B4;
}
.attn-word.selected {
  background: #47F5B4;
  color: #0B0F0D;
  border-color: #47F5B4;
  font-weight: 700;
}
.attention-viz-container {
  margin-top: 1rem;
  background: var(--theme);
  padding: 1rem;
  border-radius: 8px;
  border: 1px solid var(--border);
}
.active-query-label {
  font-size: 0.82rem;
  color: var(--secondary);
  margin-bottom: 0.8rem;
}
.highlight-word {
  color: #47F5B4;
  font-weight: 700;
}
.attention-bar-row {
  display: flex;
  align-items: center;
  margin-bottom: 0.45rem;
  gap: 0.8rem;
  font-size: 0.8rem;
}
.attn-target-word {
  width: 70px;
  text-align: right;
  font-family: monospace;
  font-weight: 600;
}
.attn-bar-track {
  flex: 1;
  height: 16px;
  background: rgba(125, 125, 125, 0.12);
  border-radius: 4px;
  overflow: hidden;
  position: relative;
}
.attn-bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #47F5B4, #2cd396);
  border-radius: 4px;
  transition: width 0.3s ease;
}
.attn-score-val {
  width: 45px;
  font-size: 0.74rem;
  color: var(--secondary);
  font-family: monospace;
}

/* Sampling styles */
.prompt-box {
  background: var(--theme);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 0.8rem 1rem;
  font-size: 0.92rem;
  line-height: 1.5;
  margin-bottom: 1rem;
}
.prompt-prefix {
  font-size: 0.72rem;
  text-transform: uppercase;
  font-weight: 700;
  color: var(--secondary);
  display: block;
  margin-bottom: 0.2rem;
}
.prompt-text {
  font-weight: 500;
}
.prompt-next {
  color: #47F5B4;
  font-style: italic;
  margin-left: 0.3rem;
  animation: pulse 1.5s infinite;
}
.controls-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.2rem;
  margin-bottom: 1.2rem;
}
@media (max-width: 600px) {
  .controls-row { grid-template-columns: 1fr; }
}
.slider-label {
  display: flex;
  justify-content: space-between;
  font-size: 0.8rem;
  margin-bottom: 0.4rem;
}
.slider-label .tip {
  font-size: 0.72rem;
  color: var(--secondary);
}
input[type="range"] {
  width: 100%;
  accent-color: #47F5B4;
  cursor: pointer;
}
.distribution-view {
  background: var(--theme);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 0.8rem 1rem;
}
.dist-header {
  display: flex;
  justify-content: space-between;
  font-size: 0.72rem;
  color: var(--secondary);
  text-transform: uppercase;
  border-bottom: 1px solid var(--border);
  padding-bottom: 0.4rem;
  margin-bottom: 0.5rem;
}
.dist-row {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  margin-bottom: 0.45rem;
  font-size: 0.82rem;
}
.dist-word {
  width: 110px;
  font-family: monospace;
  font-weight: 600;
}
.dist-logit {
  width: 45px;
  font-size: 0.72rem;
  color: var(--secondary);
  font-family: monospace;
}
.dist-bar-track {
  flex: 1;
  height: 14px;
  background: rgba(125, 125, 125, 0.12);
  border-radius: 3px;
  overflow: hidden;
}
.dist-bar-fill {
  height: 100%;
  background: #47F5B4;
  transition: width 0.25s ease;
}
.dist-prob {
  width: 50px;
  text-align: right;
  font-size: 0.76rem;
  font-family: monospace;
  font-weight: 600;
}
.sampling-actions {
  display: flex;
  gap: 0.8rem;
  margin-top: 1rem;
  flex-wrap: wrap;
}
.action-btn {
  background: #47F5B4;
  color: #0B0F0D;
  border: none;
  padding: 0.55rem 1rem;
  border-radius: 6px;
  font-size: 0.82rem;
  font-weight: 600;
  cursor: pointer;
  transition: opacity 0.2s ease;
}
.action-btn:hover {
  opacity: 0.9;
}
.action-btn.secondary {
  background: transparent;
  color: var(--primary);
  border: 1px solid var(--border);
}
.action-btn.secondary:hover {
  background: rgba(125, 125, 125, 0.1);
}
@keyframes pulse {
  0%, 100% { opacity: 0.4; }
  50% { opacity: 1; }
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(4px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>

<script>
// ==========================================
// 1. TOKENIZER SIMULATOR
// ==========================================
const tokenColors = [
  '#e6f7ff', '#fff1f0', '#f6ffed', '#fffbe6', '#f9f0ff', '#e6fffb', '#fff0f6'
];
const tokenBorderColors = [
  '#91d5ff', '#ffa39e', '#b7eb8f', '#ffe58f', '#d3adf7', '#87e8de', '#ffadd2'
];

function hashString(str) {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash = (hash << 5) - hash + str.charCodeAt(i);
    hash |= 0;
  }
  return Math.abs(hash);
}

function pseudoTokenize(text) {
  if (!text) return [];
  // Approximate BPE subword splitting heuristic for demonstration
  const rawTokens = [];
  const words = text.split(/(\s+|[.,!?:;'"(){}\[\]\/\\=+\-*])/);
  for (let w of words) {
    if (!w) continue;
    if (w.length > 5 && !w.startsWith(' ') && Math.random() > 0.5) {
      const mid = Math.floor(w.length / 2);
      rawTokens.push(w.slice(0, mid));
      rawTokens.push(w.slice(mid));
    } else {
      rawTokens.push(w);
    }
  }
  return rawTokens;
}

function updateTokenizer() {
  const input = document.getElementById('tok-input');
  const display = document.getElementById('token-display');
  const countEl = document.getElementById('token-count');
  const charEl = document.getElementById('char-count');
  const ratioEl = document.getElementById('ratio-count');

  if (!input || !display) return;
  const text = input.value;
  const tokens = pseudoTokenize(text);

  countEl.innerText = tokens.length;
  charEl.innerText = text.length;
  ratioEl.innerText = tokens.length ? (text.length / tokens.length).toFixed(1) : "0";

  display.innerHTML = '';
  tokens.forEach((t, i) => {
    const badge = document.createElement('span');
    badge.className = 'token-badge';
    const colorIdx = i % tokenColors.length;
    badge.style.backgroundColor = tokenColors[colorIdx];
    badge.style.borderColor = tokenBorderColors[colorIdx];
    badge.style.color = '#111827';

    const cleanDisplay = t === ' ' ? '␣' : (t === '\n' ? '↵' : t);
    const id = 1000 + (hashString(t) % 98000);
    badge.innerHTML = `<span>${cleanDisplay}</span><span class="token-id">#${id}</span>`;
    display.appendChild(badge);
  });
}

function setTokenText(str) {
  const input = document.getElementById('tok-input');
  if (input) {
    input.value = str;
    updateTokenizer();
  }
}

// ==========================================
// 2. ATTENTION MATRIX SIMULATOR
// ==========================================
const attentionSentence = ["The", "animal", "didn't", "cross", "the", "street", "because", "it", "was", "too", "tired"];
const attentionWeightsTable = {
  "it": {
    "The": 0.02, "animal": 0.58, "didn't": 0.03, "cross": 0.04, "the": 0.02,
    "street": 0.08, "because": 0.05, "it": 0.04, "was": 0.03, "too": 0.03, "tired": 0.08
  },
  "tired": {
    "The": 0.01, "animal": 0.44, "didn't": 0.04, "cross": 0.03, "the": 0.01,
    "street": 0.04, "because": 0.08, "it": 0.22, "was": 0.05, "too": 0.06, "tired": 0.02
  },
  "animal": {
    "The": 0.25, "animal": 0.40, "didn't": 0.08, "cross": 0.12, "the": 0.02,
    "street": 0.05, "because": 0.02, "it": 0.01, "was": 0.01, "too": 0.01, "tired": 0.03
  },
  "cross": {
    "The": 0.05, "animal": 0.28, "didn't": 0.15, "cross": 0.22, "the": 0.08,
    "street": 0.18, "because": 0.01, "it": 0.01, "was": 0.01, "too": 0.00, "tired": 0.01
  },
  "street": {
    "The": 0.03, "animal": 0.08, "didn't": 0.02, "cross": 0.32, "the": 0.35,
    "street": 0.14, "because": 0.01, "it": 0.01, "was": 0.01, "too": 0.01, "tired": 0.02
  }
};

function initAttentionDemo() {
  const row = document.getElementById('sentence-tokens');
  if (!row) return;
  row.innerHTML = '';

  attentionSentence.forEach(word => {
    const btn = document.createElement('button');
    btn.className = 'attn-word' + (word === 'it' ? ' selected' : '');
    btn.innerText = word;
    btn.onclick = () => selectQueryWord(word);
    row.appendChild(btn);
  });
  renderAttentionWeights('it');
}

function selectQueryWord(word) {
  document.querySelectorAll('.attn-word').forEach(el => {
    el.classList.toggle('selected', el.innerText === word);
  });
  const label = document.getElementById('current-query-word');
  if (label) label.innerText = `"${word}"`;
  renderAttentionWeights(word);
}

function renderAttentionWeights(queryWord) {
  const container = document.getElementById('attention-bars');
  if (!container) return;
  container.innerHTML = '';

  // Get known weights or synthesize fallback
  let weights = attentionWeightsTable[queryWord];
  if (!weights) {
    weights = {};
    let sum = 0;
    attentionSentence.forEach(w => {
      const r = Math.random() + (w === queryWord ? 1.5 : 0.2);
      weights[w] = r;
      sum += r;
    });
    attentionSentence.forEach(w => weights[w] = Number((weights[w] / sum).toFixed(2)));
  }

  attentionSentence.forEach(word => {
    const score = weights[word] || 0.02;
    const pct = (score * 100).toFixed(1);

    const row = document.createElement('div');
    row.className = 'attention-bar-row';
    row.innerHTML = `
      <span class="attn-target-word">${word}</span>
      <div class="attn-bar-track">
        <div class="attn-bar-fill" style="width: ${pct}%;"></div>
      </div>
      <span class="attn-score-val">${score.toFixed(2)}</span>
    `;
    container.appendChild(row);
  });
}

// ==========================================
// 3. LOGITS & SAMPLING SIMULATOR
// ==========================================
const candidateTokensData = [
  { token: "healthcare", logit: 6.8 },
  { token: "humanity", logit: 6.2 },
  { token: "education", logit: 5.7 },
  { token: "industry", logit: 5.1 },
  { token: "programming", logit: 4.5 },
  { token: "everything", logit: 3.8 },
  { token: "society", logit: 3.5 },
  { token: "banana", logit: 0.6 }
];

let currentCandidates = [...candidateTokensData];

function softmax(logits, temperature) {
  const scaled = logits.map(l => l / temperature);
  const maxScaled = Math.max(...scaled);
  const exps = scaled.map(s => Math.exp(s - maxScaled));
  const sumExps = exps.reduce((a, b) => a + b, 0);
  return exps.map(e => e / sumExps);
}

function updateSamplingSim() {
  const tempSlider = document.getElementById('temp-slider');
  const toppSlider = document.getElementById('topp-slider');
  const tempVal = document.getElementById('temp-val');
  const toppVal = document.getElementById('topp-val');
  const descEl = document.getElementById('temp-desc');
  const container = document.getElementById('candidates-container');

  if (!tempSlider || !container) return;

  const temp = parseFloat(tempSlider.value);
  const topP = parseFloat(toppSlider.value);
  tempVal.innerText = temp.toFixed(2);
  toppVal.innerText = topP.toFixed(2);

  if (temp < 0.3) descEl.innerText = "Deterministic / Greedy";
  else if (temp <= 0.8) descEl.innerText = "Balanced & Fluent";
  else if (temp <= 1.2) descEl.innerText = "Creative & Diverse";
  else descEl.innerText = "High Entropy / Random";

  const rawLogits = currentCandidates.map(c => c.logit);
  const probs = softmax(rawLogits, temp);

  // Combine and sort
  const combined = currentCandidates.map((c, i) => ({
    token: c.token,
    logit: c.logit,
    prob: probs[i]
  })).sort((a, b) => b.prob - a.prob);

  // Apply Top-P cumulative mask
  let cumSum = 0;
  container.innerHTML = '';
  combined.forEach(item => {
    cumSum += item.prob;
    const inTopP = (cumSum - item.prob) < topP;
    const pct = (item.prob * 100).toFixed(1);

    const row = document.createElement('div');
    row.className = 'dist-row';
    row.style.opacity = inTopP ? '1' : '0.35';
    row.innerHTML = `
      <span class="dist-word">${item.token} ${!inTopP ? '<small style="color:var(--secondary)">(filtered)</small>' : ''}</span>
      <span class="dist-logit">${item.logit.toFixed(1)}</span>
      <div class="dist-bar-track">
        <div class="dist-bar-fill" style="width: ${pct}%; background: ${inTopP ? '#47F5B4' : 'var(--secondary)'};"></div>
      </div>
      <span class="dist-prob">${pct}%</span>
    `;
    container.appendChild(row);
  });
}

function sampleAndAppendToken() {
  const temp = parseFloat(document.getElementById('temp-slider').value);
  const topP = parseFloat(document.getElementById('topp-slider').value);
  const rawLogits = currentCandidates.map(c => c.logit);
  const probs = softmax(rawLogits, temp);

  const combined = currentCandidates.map((c, i) => ({
    token: c.token,
    prob: probs[i]
  })).sort((a, b) => b.prob - a.prob);

  // Filter top-P
  let cum = 0;
  const filtered = [];
  for (let c of combined) {
    filtered.push(c);
    cum += c.prob;
    if (cum >= topP) break;
  }

  // Renormalize
  const filteredSum = filtered.reduce((acc, cur) => acc + cur.prob, 0);
  const rand = Math.random() * filteredSum;
  let running = 0;
  let chosen = filtered[0].token;
  for (let c of filtered) {
    running += c.prob;
    if (rand <= running) {
      chosen = c.token;
      break;
    }
  }

  const promptEl = document.getElementById('sim-prompt');
  if (promptEl) {
    promptEl.innerText += ' ' + chosen;
  }

  // Shift candidates slightly for fun next step
  currentCandidates = currentCandidates.map(c => ({
    token: c.token,
    logit: Math.max(1.0, c.logit + (Math.random() * 2 - 1))
  }));
  updateSamplingSim();
}

function resetSamplingPrompt() {
  const promptEl = document.getElementById('sim-prompt');
  if (promptEl) {
    promptEl.innerText = "The future of artificial intelligence will revolutionize";
  }
  currentCandidates = [...candidateTokensData];
  updateSamplingSim();
}

// Initialise everything when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const tokInput = document.getElementById('tok-input');
  if (tokInput) {
    tokInput.addEventListener('input', updateTokenizer);
    updateTokenizer();
  }
  initAttentionDemo();
  updateSamplingSim();
});

// Run once immediately in case DOM is already parsed
if (document.readyState === 'complete' || document.readyState === 'interactive') {
  updateTokenizer();
  initAttentionDemo();
  updateSamplingSim();
}
</script>
