grpcurl -plaintext \
  -import-path proto \
  -proto echo.proto \
  -d '{"text":"hello"}' \
  localhost:50051 demo.EchoService/Echo
