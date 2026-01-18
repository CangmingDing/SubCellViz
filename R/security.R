#' 获取机器码
#'
#' @return 格式化的机器识别码 (xxxx-xxxx-xxxx-xxxx)
#' @export
get_machine_code <- function() {
    # 结合系统信息生成唯一标识符
    sys_info <- Sys.info()
    # 尝试获取更稳定的硬件标识符
    hw_id <- tryCatch(
        {
            if (Sys.info()["sysname"] == "Darwin") {
                # macOS
                res <- system("ioreg -rd1 -c IOPlatformExpertDevice | grep -E 'IOPlatformUUID'", intern = TRUE)
                gsub(".*\"IOPlatformUUID\" = \"(.*)\"", "\\1", res)
            } else if (Sys.info()["sysname"] == "Linux") {
                # Linux
                if (file.exists("/etc/machine-id")) {
                    readLines("/etc/machine-id", n = 1)
                } else {
                    paste(sys_info, collapse = "")
                }
            } else {
                # Windows
                res <- system("wmic csproduct get uuid", intern = TRUE)
                paste(res, collapse = "")
            }
        },
        error = function(e) paste(sys_info, collapse = "")
    )

    raw_str <- paste0(hw_id, sys_info["user"], sys_info["nodename"])
    # MD5 摘要
    hash <- digest::digest(raw_str, algo = "md5")

    # 格式化为 xxxx-xxxx-xxxx-xxxx
    formatted <- paste(
        substr(hash, 1, 4),
        substr(hash, 5, 8),
        substr(hash, 9, 12),
        substr(hash, 13, 16),
        sep = "-"
    )
    return(toupper(formatted))
}

#' 验证激活码
#'
#' @param activation_code 用户输入的激活码
#' @return 逻辑值
#' @keywords internal
verify_activation <- function(activation_code) {
    if (missing(activation_code) || is.null(activation_code) || activation_code == "") {
        return(FALSE)
    }

    machine_code <- get_machine_code()
    # MD5(machine_code_formatted + salt)
    salt <- "SUBCELLVIZ_SECURE_SALT_2026_DTN"
    expected_code <- digest::digest(paste0(machine_code, salt), algo = "md5")

    return(activation_code == expected_code)
}

#' 获取授权文件路径
#' @keywords internal
get_license_path <- function() {
    file.path(Sys.getenv("HOME"), ".subcellviz_license")
}

#' 激活 SubCellViz 包
#'
#' @description
#' 输入作者提供的激活码，永久激活当前机器。
#'
#' @param activation_code 激活码字符串
#' @return 成功返回 TRUE，否则抛出错误
#' @export
activate_subcellviz <- function(activation_code) {
    if (verify_activation(activation_code)) {
        writeLines(activation_code, get_license_path())
        message("激活成功！您的 SubCellViz 包已永久激活。")
        return(invisible(TRUE))
    } else {
        stop(sprintf("\n[激活失败 / Activation Failed]\n无效的激活码！\n您的机器码是：%s\n\n请联系作者获取激活码：\n邮箱：20220123072@bucm.edu.cn\n微信：CangMing-03", get_machine_code()))
    }
}

#' 检查激活状态
#' @param activation_code 可选的一次性激活码
#' @keywords internal
check_auth <- function(activation_code = NULL) {
    # 1. 检查提供的一次性激活码
    if (!is.null(activation_code) && verify_activation(activation_code)) {
        return(TRUE)
    }

    # 2. 检查本地授权文件
    lic_path <- get_license_path()
    if (file.exists(lic_path)) {
        saved_code <- readLines(lic_path, n = 1, warn = FALSE)
        if (verify_activation(saved_code)) {
            return(TRUE)
        }
    }

    # 3. 验证失败
    stop(sprintf("\n[软件未激活 / SubCellViz Not Activated]\n请先运行：activate_subcellviz('您的激活码') 进行永久激活。\n您的机器码是：%s\n\n联系作者获取激活码：\n邮箱：20220123072@bucm.edu.cn\n微信：CangMing-03", get_machine_code()))
}
