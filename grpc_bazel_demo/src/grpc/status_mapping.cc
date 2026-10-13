#include "src/grpc/status_mapping.h"

namespace demo {

grpc::Status ToGrpcStatus(const absl::Status& status) {
  if (status.ok()) return grpc::Status::OK;

  switch (status.code()) {
    case absl::StatusCode::kNotFound:
      return grpc::Status(grpc::StatusCode::NOT_FOUND, std::string(status.message()));
    case absl::StatusCode::kInvalidArgument:
      return grpc::Status(grpc::StatusCode::INVALID_ARGUMENT, std::string(status.message()));
    case absl::StatusCode::kPermissionDenied:
      return grpc::Status(grpc::StatusCode::PERMISSION_DENIED, std::string(status.message()));
    case absl::StatusCode::kUnauthenticated:
      return grpc::Status(grpc::StatusCode::UNAUTHENTICATED, std::string(status.message()));
    case absl::StatusCode::kAlreadyExists:
      return grpc::Status(grpc::StatusCode::ALREADY_EXISTS, std::string(status.message()));
    case absl::StatusCode::kDeadlineExceeded:
      return grpc::Status(grpc::StatusCode::DEADLINE_EXCEEDED, std::string(status.message()));
    case absl::StatusCode::kUnavailable:
      return grpc::Status(grpc::StatusCode::UNAVAILABLE, std::string(status.message()));
    default:
      return grpc::Status(grpc::StatusCode::INTERNAL, std::string(status.message()));
  }
}

}  // namespace demo
