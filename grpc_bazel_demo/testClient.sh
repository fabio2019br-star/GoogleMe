.proto  →  cc_grpc_library  →  EchoServiceGrpc  →  EchoLogicImpl
   ↑                                                    ↓
grpcurl ← gRPC server ← builder ← main.cc ←──────────────┘


grpcurl -plaintext \
  -import-path proto \
  -proto echo.proto \
  -d '{"text":""}' \
  localhost:50051 demo.EchoService/Echo
