#pragma once

namespace fake_spdlog {
template <typename... Args> void log(Args&&...) {
}
} // namespace fake_spdlog

#define SPDLOG_DEBUG(...) fake_spdlog::log(__VA_ARGS__)
#define SPDLOG_ERROR(...) fake_spdlog::log(__VA_ARGS__)
#define SPDLOG_INFO(...) fake_spdlog::log(__VA_ARGS__)
#define SPDLOG_WARN(...) fake_spdlog::log(__VA_ARGS__)
