# 2. TSan (data races) — separado do ASan
bazel test //... --config=tsan

# 3. Sem sanitizer (baseline, já passou)
bazel test //...
