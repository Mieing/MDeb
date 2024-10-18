#import <Foundation/Foundation.h>
#include <spawn.h>
#include <sys/wait.h>

void createDirectories() {
    [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Documents/Mdeb/deb" withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Documents/Mdeb/dylib" withIntermediateDirectories:YES attributes:nil error:nil];
    printf("Directories created.\n");
}

void extractDylibs() {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *debDirectory = @"/var/mobile/Documents/Mdeb/deb";
    NSString *dylibDirectory = @"/var/mobile/Documents/Mdeb/dylib";

    NSArray *debFiles = [fileManager contentsOfDirectoryAtPath:debDirectory error:nil];
    for (NSString *debFile in debFiles) {
        if ([debFile.pathExtension isEqualToString:@"deb"]) {
            NSString *debFilePath = [debDirectory stringByAppendingPathComponent:debFile];
            NSString *tempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];

            // Create temporary directory
            [fileManager createDirectoryAtPath:tempDirectory withIntermediateDirectories:YES attributes:nil error:nil];

            // Extract .deb file
            char *argv[] = {"dpkg-deb", "-x", (char *)[debFilePath UTF8String], (char *)[tempDirectory UTF8String], NULL};
            posix_spawn_file_actions_t file_actions;
            posix_spawn_file_actions_init(&file_actions);
            pid_t pid;
            int status = posix_spawnp(&pid, "dpkg-deb", &file_actions, NULL, argv, NULL);
            posix_spawn_file_actions_destroy(&file_actions);

            if (status == 0) {
                if (waitpid(pid, &status, 0) == -1) {
                    perror("waitpid");
                } else {
                    printf("Extracted: %s\n", [debFile UTF8String]);
                }
            } else {
                printf("posix_spawn: %s\n", strerror(status));
            }

            // Move .dylib files to /var/mobile/Documents/Mdeb/dylib
            NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:tempDirectory];
            NSString *file;
            while ((file = [enumerator nextObject])) {
                if ([file.pathExtension isEqualToString:@"dylib"]) {
                    NSString *sourcePath = [tempDirectory stringByAppendingPathComponent:file];
                    NSString *destinationPath = [dylibDirectory stringByAppendingPathComponent:[file lastPathComponent]];
                    NSError *moveError = nil;
                    [fileManager moveItemAtPath:sourcePath toPath:destinationPath error:&moveError];
                    if (moveError) {
                        printf("Failed to move %s: %s\n", [file UTF8String], [[moveError localizedDescription] UTF8String]);
                    } else {
                        printf("Moved: %s\n", [file UTF8String]);
                    }
                }
            }

            // Remove temporary directory
            [fileManager removeItemAtPath:tempDirectory error:nil];
        }
    }
}

void printUsage() {
    // ANSI 转义码设置红色
    const char *red = "\033[31m";
    // ANSI 转义码重置颜色
    const char *reset = "\033[0m";

    // 使用转义码
    printf("%s用法:mdeb -tq%s\n", red, reset);
    printf("\n");
    printf("%s参数:-tq  要处理的.deb 文件放在 /var/mobile/Documents/Mdeb/deb 提取后的dylib在 /var/mobile/Documents/Mdeb%s\n", red, reset);
    printf("\n");
    printf("%s关于:mdeb v5.2.0 2024.8.7 by @mie https://github.com/Mieing%s\n", red, reset);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc > 1 && strcmp(argv[1], "-tq") == 0) {
            printf("Processing -tq argument.\n");
            createDirectories();
            extractDylibs();
        } else {
            createDirectories();
            printUsage();
        }
    }
    return 0;
}
