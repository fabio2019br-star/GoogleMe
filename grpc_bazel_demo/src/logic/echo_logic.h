#pragma once

#include <string>

#include "absl/status/statusor.h"

namespace demo {

class EchoLogic {
 public:
  virtual ~EchoLogic() = default;
  virtual absl::StatusOr<std::string> Echo(const std::string& text) = 0;
};

}  // namespace demo
