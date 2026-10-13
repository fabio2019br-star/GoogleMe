#include "src/grpc/status_mapping.h"

#include <gtest/gtest.h>

#include "absl/status/status.h"

namespace demo {
namespace {

struct StatusCase {
  absl::StatusCode absl_code;
  grpc::StatusCode expected_grpc_code;
};

class StatusMappingTest : public ::testing::TestWithParam<StatusCase> {};

TEST_P(StatusMappingTest, MapsCorrectly) {
  const auto& p = GetParam();
  absl::Status absl_status(p.absl_code, "msg");
  auto grpc_status = ToGrpcStatus(absl_status);
  EXPECT_EQ(grpc_status.error_code(), p.expected_grpc_code);
  EXPECT_EQ(grpc_status.error_message(), "msg");
}

INSTANTIATE_TEST_SUITE_P(
    AllMappings, StatusMappingTest,
    ::testing::Values(
        StatusCase{absl::StatusCode::kNotFound, grpc::StatusCode::NOT_FOUND},
        StatusCase{absl::StatusCode::kInvalidArgument, grpc::StatusCode::INVALID_ARGUMENT},
        StatusCase{absl::StatusCode::kPermissionDenied, grpc::StatusCode::PERMISSION_DENIED},
        StatusCase{absl::StatusCode::kUnauthenticated, grpc::StatusCode::UNAUTHENTICATED},
        StatusCase{absl::StatusCode::kAlreadyExists, grpc::StatusCode::ALREADY_EXISTS},
        StatusCase{absl::StatusCode::kDeadlineExceeded, grpc::StatusCode::DEADLINE_EXCEEDED},
        StatusCase{absl::StatusCode::kUnavailable, grpc::StatusCode::UNAVAILABLE},
        StatusCase{absl::StatusCode::kInternal, grpc::StatusCode::INTERNAL},
        StatusCase{absl::StatusCode::kUnknown, grpc::StatusCode::INTERNAL}));

TEST(StatusMappingTest, OkStatusMapsToOk) {
  EXPECT_TRUE(ToGrpcStatus(absl::OkStatus()).ok());
}

}  // namespace
}  // namespace demo
