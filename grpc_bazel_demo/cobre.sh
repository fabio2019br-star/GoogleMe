cd ~/dev/suport/molduras/molduras/Gooogleeeee/abseil/grpc_bazel_demo

# 1. ASan + UBSan (o mais útil no dia a dia)
bazel test //... --config=asan_ubsan
