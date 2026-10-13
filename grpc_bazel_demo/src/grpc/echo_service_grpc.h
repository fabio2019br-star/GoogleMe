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
