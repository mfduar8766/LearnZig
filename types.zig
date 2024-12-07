pub const LogLevels = enum(u2) {
    INFO = 0,
    WARNING = 1,
    ERROR = 2,
    FATAL = 3,
    pub fn get(key: u2) []const u8 {
        return switch (key) {
            0 => "INFO",
            1 => "WARNING",
            2 => "ERROR",
            3 => "FATAL",
        };
    }
};

pub const ErrorTypes = enum(u8) {
    FileNotFound,
    AccessDenied,
    NameTooLong,
    NotSupported,
    NotDir,
    SymLinkLoop,
    InputOutput,
    FileTooBig,
    IsDir,
    ProcessFdQuotaExceeded,
    SystemFdQuotaExceeded,
    NoDevice,
    SystemResources,
    NoSpaceLeft,
    FileSystem,
    BadPathName,
    DeviceBusy,
    SharingViolation,
    PipeBusy,
    NotLink,
    PathAlreadyExists,
    pub fn getErrorName(key: u8) [:0]const u8 {
        return switch (key) {
            0 => @errorName(error.FileNotFound),
            1 => "WARNING",
            2 => "ERROR",
            3 => "FATAL",
        };
    }
    // pub fn get(name: [:0]const u8) bool {
    //     var gpaAlloc = std.heap.GeneralPurposeAllocator(.{}){};
    //     defer _ = gpaAlloc.deinit();
    //     const allocator = gpaAlloc.allocator();
    //     var set = std.AutoHashMap(usize, void).init(allocator);
    //     defer set.deinit();
    //     try set.put(error.FileNotFound, true);
    // }
};

pub const Suit = enum {
    clubs,
    spades,
    diamonds,
    hearts,
    pub fn isClubs(self: Suit) bool {
        return self == Suit.clubs;
    }
};
