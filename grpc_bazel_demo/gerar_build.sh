# Camada 1: geração do proto
bazel build //proto:echo_cc_grpc

# Camada 2: lógica pura
bazel build //src/logic:echo_logic

# Camada 3: camada gRPC
bazel build //src/grpc:echo_service_grpc

# Camada 4: binário do servidor
bazel build //server
