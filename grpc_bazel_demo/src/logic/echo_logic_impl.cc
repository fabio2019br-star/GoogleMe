#include "src/logic/echo_logic_impl.h"

#include "absl/status/status.h"

namespace demo {

absl::StatusOr<std::string> EchoLogicImpl::Echo(const std::string& text) {
  if (text.empty()) {
    return absl::InvalidArgumentError("text must not be empty");
  }
  return text;
}

}  // namespace demo
