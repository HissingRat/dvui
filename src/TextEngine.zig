const dvui = @import("dvui.zig");

const TextEngine = @This();

context: *anyopaque,
vtable: *const VTable,

pub const VTable = struct {
    deinit: ?*const fn (
        context: *anyopaque,
    ) void = null,
    measure: *const fn (
        context: *anyopaque,
        font: dvui.Font,
        text: []const u8,
        options: dvui.Font.TextSizeOptions,
    ) dvui.Size,
    render: *const fn (
        context: *anyopaque,
        options: RenderOptions,
    ) anyerror!void,
    caret_x: *const fn (
        context: *anyopaque,
        font: dvui.Font,
        text: []const u8,
        byte_offset: usize,
    ) f32,
    caret_point: *const fn (
        context: *anyopaque,
        font: dvui.Font,
        text: []const u8,
        byte_offset: usize,
        wrap_width: ?f32,
    ) dvui.Point,
    previous_boundary: *const fn (
        context: *anyopaque,
        font: dvui.Font,
        text: []const u8,
        byte_offset: usize,
    ) usize,
    next_boundary: *const fn (
        context: *anyopaque,
        font: dvui.Font,
        text: []const u8,
        byte_offset: usize,
    ) usize,
};

pub const RenderOptions = struct {
    font: dvui.Font,
    text: []const u8,
    rs: dvui.RectScale,
    p: ?dvui.Point.Physical = null,
    color: dvui.Color,
    sel_start: ?usize = null,
    sel_end: ?usize = null,
    sel_color: ?dvui.Color = null,
    rotation: f32 = 0,
    background_color: ?dvui.Color = null,
    debug: bool = false,
    kerning: ?bool = null,
};

pub fn deinit(self: TextEngine) void {
    if (self.vtable.deinit) |deinit_fn| {
        deinit_fn(self.context);
    }
}

pub fn measure(
    self: TextEngine,
    font: dvui.Font,
    text: []const u8,
    options: dvui.Font.TextSizeOptions,
) dvui.Size {
    return self.vtable.measure(self.context, font, text, options);
}

pub fn render(self: TextEngine, options: RenderOptions) anyerror!void {
    return self.vtable.render(self.context, options);
}

pub fn caretX(
    self: TextEngine,
    font: dvui.Font,
    text: []const u8,
    byte_offset: usize,
) f32 {
    return self.vtable.caret_x(self.context, font, text, @min(byte_offset, text.len));
}

pub fn caretPoint(
    self: TextEngine,
    font: dvui.Font,
    text: []const u8,
    byte_offset: usize,
    wrap_width: ?f32,
) dvui.Point {
    return self.vtable.caret_point(
        self.context,
        font,
        text,
        @min(byte_offset, text.len),
        wrap_width,
    );
}

pub fn previousBoundary(
    self: TextEngine,
    font: dvui.Font,
    text: []const u8,
    byte_offset: usize,
) usize {
    return @min(
        byte_offset,
        self.vtable.previous_boundary(self.context, font, text, @min(byte_offset, text.len)),
    );
}

pub fn nextBoundary(
    self: TextEngine,
    font: dvui.Font,
    text: []const u8,
    byte_offset: usize,
) usize {
    return @min(
        text.len,
        self.vtable.next_boundary(self.context, font, text, @min(byte_offset, text.len)),
    );
}
