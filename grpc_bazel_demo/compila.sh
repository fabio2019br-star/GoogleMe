cd grpc_bazel_demo

bazel build //proto:echo_cc_grpc && \
bazel build //src/logic:echo_logic && \
bazel build //src/grpc:echo_service_grpc && \
bazel build //server && \
bazel test //tests/unit/... && \
bazel test //tests/integration/... && \
bazel test //...
