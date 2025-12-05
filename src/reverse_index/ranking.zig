const posting = @import("posting.zig");

pub fn df(postings: *const posting.Postings) usize {
    return postings.docs.items.len;
}

pub fn idf(postings: *const posting.Postings, total_docs: u32) f64 {
    const doc_freq = postings.docs.items.len;
    if (doc_freq == 0 or total_docs == 0) return 0;
    return @log(@as(f64, @floatFromInt(total_docs)) / @as(f64, @floatFromInt(doc_freq)));
}
