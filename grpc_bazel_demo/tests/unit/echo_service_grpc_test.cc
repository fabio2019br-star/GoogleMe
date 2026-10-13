#include "src/grpc/echo_service_grpc.h"

#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include "absl/status/status.h"
#include "tests/mocks/echo_logic_mock.h"

namespace demo {
namespace {

using ::testing::_;
using ::testing::Return;
using ::absl::InvalidArgumentError;

class EchoServiceGrpcTest : public ::testing::Test {
 protected:
  MockEchoLogic logic_;
  EchoServiceGrpc service_{&logic_};
  grpc::ServerContext ctx_;
};

TEST_F(EchoServiceGrpcTest, Echo_ReturnsSameText_OnSuccess) {
  EXPECT_CALL(logic_, Echo("hello")).WillOnce(Return(std::string("hello")));

  EchoRequest req;
  req.set_text("hello");
  EchoResponse resp;

  auto status = service_.Echo(&ctx_, &req, &resp);

  EXPECT_TRUE(status.ok());
  EXPECT_EQ(resp.text(), "hello");
}

TEST_F(EchoServiceGrpcTest, Echo_MapsInvalidArgument) {
  EXPECT_CALL(logic_, Echo("")).WillOnce(Return(InvalidArgumentError("empty")));

  EchoRequest req;
  EchoResponse resp;

  auto status = service_.Echo(&ctx_, &req, &resp);

  EXPECT_EQ(status.error_code(), grpc::StatusCode::INVALID_ARGUMENT);
  EXPECT_EQ(status.error_message(), "empty");
}

}  // namespace
}  // namespace demo
