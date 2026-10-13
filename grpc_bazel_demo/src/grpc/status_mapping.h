#pragma once

#include <grpcpp/grpcpp.h>

#include "absl/status/status.h"

namespace demo {

grpc::Status ToGrpcStatus(const absl::Status& status);

}  // namespace demo
