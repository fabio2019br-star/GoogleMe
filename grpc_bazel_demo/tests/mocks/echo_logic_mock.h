#pragma once

#include <gmock/gmock.h>

#include "src/logic/echo_logic.h"

namespace demo {

class MockEchoLogic : public EchoLogic {
 public:
  MOCK_METHOD(absl::StatusOr<std::string>, Echo, (const std::string&), (override));
};

}  // namespace demo
