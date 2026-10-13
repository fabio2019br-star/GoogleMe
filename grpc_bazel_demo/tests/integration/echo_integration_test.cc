#include <memory>

#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <grpcpp/grpcpp.h>

#include "proto/echo.grpc.pb.h"
#include "src/grpc/echo_service_grpc.h"
#include "tests/mocks/echo_logic_mock.h"

namespace demo {
namespace {

using ::testing::Return;

class EchoIntegrationTest : public ::testing::Test {
 protected:
  void SetUp() override {
    grpc::ServerBuilder builder;
    builder.RegisterService(&service_);
    server_ = builder.BuildAndStart();
    ASSERT_NE(server_, nullptr);

    auto channel = server_->InProcessChannel(grpc::ChannelArguments());
    stub_ = EchoService::NewStub(channel);
  }

  void TearDown() override {
    server_->Shutdown();
    server_->Wait();
  }

  MockEchoLogic logic_;
  EchoServiceGrpc service_{&logic_};
  std::unique_ptr<grpc::Server> server_;
  std::unique_ptr<EchoService::Stub> stub_;
};

TEST_F(EchoIntegrationTest, Echo_RoundTrips) {
  EXPECT_CALL(logic_, Echo("ping")).WillOnce(Return(std::string("pong")));

  grpc::ClientContext ctx;
  EchoRequest req;
  req.set_text("ping");
  EchoResponse resp;

  auto status = stub_->Echo(&ctx, req, &resp);

  EXPECT_TRUE(status.ok()) << status.error_message();
  EXPECT_EQ(resp.text(), "pong");
}

TEST_F(EchoIntegrationTest, Echo_PropagatesInvalidArgument) {
  EXPECT_CALL(logic_, Echo("")).WillOnce(Return(absl::InvalidArgumentError("empty")));

  grpc::ClientContext ctx;
  EchoRequest req;
  EchoResponse resp;

  auto status = stub_->Echo(&ctx, req, &resp);

  EXPECT_EQ(status.error_code(), grpc::StatusCode::INVALID_ARGUMENT);
}

}  // namespace
}  // namespace demo
