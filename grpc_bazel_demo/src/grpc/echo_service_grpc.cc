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
