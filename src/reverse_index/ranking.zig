const posting = @import("posting.zig");

// classic TF-IDF log(total_docs / doc_freq)
pub fn idf(postings: *const posting.Postings, total_docs: u32) f64 {
    const doc_freq = postings.documentFrequency();
    if (doc_freq == 0 or total_docs == 0) return 0;
    return @log(@as(f64, @floatFromInt(total_docs)) / @as(f64, @floatFromInt(doc_freq)));
}

// BM25-IDF ln((N - n(qi) + 0.5) / (n(qi) + 0.5) + 1)
// N = total docs in collection
// n(qi) = docs containing the term (document frequency)
// N - n(qi) = docs that do not contain the term
pub fn bm25idf(postings: *const posting.Postings, total_docs: u32) f64 {
    const doc_freq: f64 = @floatFromInt(postings.documentFrequency());
    const n: f64 = @floatFromInt(total_docs);
    if (doc_freq == 0 or total_docs == 0) return 0;
    return @log((n - doc_freq + 0.5) / (doc_freq + 0.5) + 1.0);
}

// BM25 term saturation constant
// Controls how quickly term frequency saturates (higher = slower saturation)
pub const BM25_K1: f64 = 1.2;

// BM25 term score (without length normalization)
// Formula: IDF × (tf × (k1 + 1)) / (tf + k1)
// - IDF: inverse document frequency (rare terms score higher)
// - tf: term frequency in document
// - k1: saturation parameter (prevents high TF from dominating)
pub fn bm25TermScore(term_freq: u8, idf_value: f64) f64 {
    const tf: f64 = @floatFromInt(term_freq);
    const numerator = tf * (BM25_K1 + 1.0);
    const denominator = tf + BM25_K1;
    return idf_value * numerator / denominator;
}
