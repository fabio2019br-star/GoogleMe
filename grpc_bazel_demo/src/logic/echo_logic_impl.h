#pragma once

#include "src/logic/echo_logic.h"

namespace demo {

class EchoLogicImpl : public EchoLogic {
 public:
  absl::StatusOr<std::string> Echo(const std::string& text) override;
};

}  // namespace demo
