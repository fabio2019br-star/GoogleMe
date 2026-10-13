
#!/usr/bin/env bash
#
# bootstrap_grpc_bazel_demo.sh
#
# Cria o projeto grpc_bazel_demo do zero:
#   proto/ + src/logic/ + src/grpc/ + server/ + tests/{mocks,unit,integration}/
#
# Uso:
#   chmod +x bootstrap_grpc_bazel_demo.sh
#   ./bootstrap_grpc_bazel_demo.sh [diretório_destino]
#
# Se o diretório já existir, os arquivos são sobrescritos (idempotente).

set -euo pipefail

DEST="${1:-grpc_bazel_demo}"

echo ">>> Criando projeto em: ${DEST}"
mkdir -p "${DEST}"
cd "${DEST}"

# ---------------------------------------------------------------------------
# Arquivos de raiz
# ---------------------------------------------------------------------------

cat > .bazelrc <<'EOF'
common --enable_bzlmod
common --cxxopt=-std=c++17
test --test_output=errors
EOF

cat > .gitignore <<'EOF'
bazel-*
EOF

cat > MODULE.bazel <<'EOF'
module(
    name = "grpc_bazel_demo",
    version = "0.1.0",
)

bazel_dep(name = "rules_cc", version = "0.0.9")
bazel_dep(name = "rules_proto", version = "6.0.0")
bazel_dep(name = "protobuf", version = "27.0")
bazel_dep(name = "grpc", version = "1.65.0")
bazel_dep(name = "googletest", version = "1.14.0")
bazel_dep(name = "abseil-cpp", version = "20240116.2")
EOF

cat > BUILD.bazel <<'EOF'
# pacote raiz — sem targets por enquanto
EOF

# ---------------------------------------------------------------------------
# proto/
# ---------------------------------------------------------------------------

mkdir -p proto

cat > proto/echo.proto <<'EOF'
syntax = "proto3";

package demo;

service EchoService {
  rpc Echo(EchoRequest) returns (EchoResponse);
}

message EchoRequest {
  string text = 1;
}

message EchoResponse {
  string text = 1;
}
EOF

cat > proto/BUILD.bazel <<'EOF'
load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_cc//cc:defs.bzl", "cc_proto_library")
load("@grpc//bazel:cc_grpc_library.bzl", "cc_grpc_library")

proto_library(
    name = "echo_proto",
    srcs = ["echo.proto"],
    visibility = ["//visibility:public"],
)

cc_proto_library(
    name = "echo_cc_proto",
    deps = [":echo_proto"],
    visibility = ["//visibility:public"],
)

cc_grpc_library(
    name = "echo_cc_grpc",
    srcs = [":echo_proto"],
    grpc_only = True,
    deps = [":echo_cc_proto"],
    visibility = ["//visibility:public"],
)
EOF

# ---------------------------------------------------------------------------
# src/logic/
# ---------------------------------------------------------------------------

mkdir -p src/logic

cat > src/logic/echo_logic.h <<'EOF'
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
EOF

cat > src/logic/echo_logic_impl.h <<'EOF'
#pragma once

#include "src/logic/echo_logic.h"

namespace demo {

class EchoLogicImpl : public EchoLogic {
 public:
  absl::StatusOr<std::string> Echo(const std::string& text) override;
};

}  // namespace demo
EOF

cat > src/logic/echo_logic_impl.cc <<'EOF'
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
EOF

cat > src/logic/BUILD.bazel <<'EOF'
load("@rules_cc//cc:defs.bzl", "cc_library")

cc_library(
    name = "echo_logic",
    srcs = ["echo_logic_impl.cc"],
    hdrs = [
        "echo_logic.h",
        "echo_logic_impl.h",
    ],
    includes = ["."],
    deps = [
        "@abseil-cpp//absl/status",
        "@abseil-cpp//absl/status:statusor",
    ],
    visibility = ["//visibility:public"],
)
EOF

# ---------------------------------------------------------------------------
# src/grpc/
# ---------------------------------------------------------------------------

mkdir -p src/grpc

cat > src/grpc/status_mapping.h <<'EOF'
#pragma once

#include <grpcpp/grpcpp.h>

#include "absl/status/status.h"

namespace demo {

grpc::Status ToGrpcStatus(const absl::Status& status);

}  // namespace demo
EOF

cat > src/grpc/status_mapping.cc <<'EOF'
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
EOF

cat > src/grpc/echo_service_grpc.h <<'EOF'
#pragma once

#include <grpcpp/grpcpp.h>

#include "proto/echo.grpc.pb.h"
#include "src/logic/echo_logic.h"

namespace demo {

class EchoServiceGrpc final : public EchoService::Service {
 public:
  explicit EchoServiceGrpc(EchoLogic* logic) : logic_(logic) {}

  grpc::Status Echo(grpc::ServerContext* context,
                    const EchoRequest* request,
                    EchoResponse* response) override;

 private:
  EchoLogic* logic_;  // não possui
};

}  // namespace demo
EOF

cat > src/grpc/echo_service_grpc.cc <<'EOF'
#include "src/grpc/echo_service_grpc.h"

#include "src/grpc/status_mapping.h"

namespace demo {

grpc::Status EchoServiceGrpc::Echo(grpc::ServerContext* /*context*/,
                                    const EchoRequest* request,
                                    EchoResponse* response) {
  auto result = logic_->Echo(request->text());
  if (!result.ok()) {
    return ToGrpcStatus(result.status());
  }
  response->set_text(*result);
  return grpc::Status::OK;
}

}  // namespace demo
EOF

cat > src/grpc/BUILD.bazel <<'EOF'
load("@rules_cc//cc:defs.bzl", "cc_library")

cc_library(
    name = "echo_service_grpc",
    srcs = [
        "echo_service_grpc.cc",
        "status_mapping.cc",
    ],
    hdrs = [
        "echo_service_grpc.h",
        "status_mapping.h",
    ],
    includes = ["."],
    deps = [
        "//proto:echo_cc_grpc",
        "//proto:echo_cc_proto",
        "//src/logic:echo_logic",
        "@abseil-cpp//absl/status",
        "@abseil-cpp//absl/status:statusor",
    ],
    visibility = ["//visibility:public"],
)
EOF

# ---------------------------------------------------------------------------
# server/
# ---------------------------------------------------------------------------

mkdir -p server

cat > server/main.cc <<'EOF'
#include <iostream>
#include <memory>

#include <grpcpp/grpcpp.h>

#include "src/grpc/echo_service_grpc.h"
#include "src/logic/echo_logic_impl.h"

int main() {
  demo::EchoLogicImpl logic;
  demo::EchoServiceGrpc service(&logic);

  std::string address("0.0.0.0:50051");
  grpc::ServerBuilder builder;
  builder.AddListeningPort(address, grpc::InsecureServerCredentials());
  builder.RegisterService(&service);

  std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
  std::cout << "Server listening on " << address << std::endl;
  server->Wait();
  return 0;
}
EOF

cat > server/BUILD.bazel <<'EOF'
load("@rules_cc//cc:defs.bzl", "cc_binary")

cc_binary(
    name = "server",
    srcs = ["main.cc"],
    deps = [
        "//src/grpc:echo_service_grpc",
        "//src/logic:echo_logic",
    ],
)
EOF

# ---------------------------------------------------------------------------
# tests/mocks/
# ---------------------------------------------------------------------------

mkdir -p tests/mocks

cat > tests/mocks/echo_logic_mock.h <<'EOF'
#pragma once

#include <gmock/gmock.h>

#include "src/logic/echo_logic.h"

namespace demo {

class MockEchoLogic : public EchoLogic {
 public:
  MOCK_METHOD(absl::StatusOr<std::string>, Echo, (const std::string&), (override));
};

}  // namespace demo
EOF

cat > tests/mocks/BUILD.bazel <<'EOF'
load("@rules_cc//cc:defs.bzl", "cc_library")

cc_library(
    name = "echo_logic_mock",
    hdrs = ["echo_logic_mock.h"],
    includes = ["."],
    deps = [
        "//src/logic:echo_logic",
        "@googletest//:gmock",
    ],
    visibility = ["//visibility:public"],
)
EOF

# ---------------------------------------------------------------------------
# tests/unit/
# ---------------------------------------------------------------------------

mkdir -p tests/unit

cat > tests/unit/status_mapping_test.cc <<'EOF'
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
EOF

cat > tests/unit/echo_service_grpc_test.cc <<'EOF'
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
EOF

cat > tests/unit/BUILD.bazel <<'EOF'
load("@rules_cc//cc:defs.bzl", "cc_test")

cc_test(
    name = "status_mapping_test",
    srcs = ["status_mapping_test.cc"],
    deps = [
        "//src/grpc:echo_service_grpc",
        "@abseil-cpp//absl/status",
        "@googletest//:gtest_main",
    ],
)

cc_test(
    name = "echo_service_grpc_test",
    srcs = ["echo_service_grpc_test.cc"],
    deps = [
        "//src/grpc:echo_service_grpc",
        "//tests/mocks:echo_logic_mock",
        "@abseil-cpp//absl/status",
        "@googletest//:gtest_main",
    ],
)
EOF

# ---------------------------------------------------------------------------
# tests/integration/
# ---------------------------------------------------------------------------

mkdir -p tests/integration

cat > tests/integration/echo_integration_test.cc <<'EOF'
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
EOF

cat > tests/integration/BUILD.bazel <<'EOF'
load("@rules_cc//cc:defs.bzl", "cc_test")

cc_test(
    name = "echo_integration_test",
    srcs = ["echo_integration_test.cc"],
    deps = [
        "//proto:echo_cc_grpc",
        "//src/grpc:echo_service_grpc",
        "//tests/mocks:echo_logic_mock",
        "@googletest//:gtest_main",
    ],
)
EOF

# ---------------------------------------------------------------------------
# Árvore final
# ---------------------------------------------------------------------------

echo
echo ">>> Árvore criada:"
find . -type f -not -path './bazel-*' | sort

echo
echo ">>> Próximos passos:"
echo "    cd ${DEST}"
echo "    bazel build //proto:echo_cc_grpc"
echo "    bazel build //src/logic:echo_logic"
echo "    bazel build //src/grpc:echo_service_grpc"
echo "    bazel build //server"
echo "    bazel test //tests/unit/..."
echo "    bazel test //tests/integration/..."
echo "    bazel test //..."
echo "    bazel run //server"
echo
echo ">>> Se o Bazel reclamar de versões no MODULE.bazel, rode:"
echo "    bazel mod tidy"
echo
echo ">>> Pronto."
