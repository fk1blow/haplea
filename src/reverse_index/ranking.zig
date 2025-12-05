const posting = @import("posting.zig");

pub fn getDocumentFrequency(postings: *const posting.Postings) usize {
    return postings.docs.items.len;
}

pub fn getInverseDocumentFrequency(postings: *const posting.Postings, total_docs: u32) f64 {
    const df = postings.docs.items.len;
    if (df == 0 or total_docs == 0) return 0;
    return @log(@as(f64, @floatFromInt(total_docs)) / @as(f64, @floatFromInt(df)));
}
