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
