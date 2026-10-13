#include <iostream>
#include <memory>

#include <grpcpp/grpcpp.h>
#include <grpcpp/ext/proto_server_reflection_plugin.h>

#include "src/grpc/echo_service_grpc.h"
#include "src/logic/echo_logic_impl.h"

int main() {
  demo::EchoLogicImpl logic;
  demo::EchoServiceGrpc service(&logic);

  std::string address("0.0.0.0:50051");
  grpc::ServerBuilder builder;
  builder.AddListeningPort(address, grpc::InsecureServerCredentials());
  builder.RegisterService(&service);

  // Habilita reflection (grpcurl, grpcui, Postman, etc.)
  grpc::reflection::InitProtoReflectionServerBuilderPlugin();

  std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
  std::cout << "Server listening on " << address << std::endl;
  server->Wait();
  return 0;
}
