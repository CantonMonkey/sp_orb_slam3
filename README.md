# SP ORB-SLAM3 (SuperPoint + LightGlue)

基于 [SP_SLAM3](https://github.com/fthbng77/SP_SLAM3) 的改进版本，使用 SuperPoint 特征提取和 LightGlue 匹配器替代 ORB 特征。

## 功能特性

- **SuperPoint 特征提取**: 端到端学习的局部特征，对光照变化、模糊鲁棒
- **LightGlue 匹配器**: Transformer-based 匹配，自适应早停，速度快于 SuperGlue
- **CLAHE 预处理**: 处理过曝/高光场景，防止描述子归一化失败
- **兼容 ORB-SLAM3 架构**: 保持原有跟踪、建图、回环检测流程

## 依赖

- OpenCV >= 3.0
- Eigen3
- Pangolin (可视化)
- LibTorch >= 1.8
- CMake >= 3.10
- CUDA (必需)

## 编译

```bash
cd ~/Sanexis/SP_SLAM3
mkdir -p build && cd build
cmake ..
make -j4
```

## 运行

```bash
cd ~/Sanexis/SP_SLAM3
./run_slam.sh
```

或完整命令：

```bash
export LD_LIBRARY_PATH=/home/xzb/Sanexis/ALIKED_CPP/external/libtorch/lib:$LD_LIBRARY_PATH

./Examples/Monocular/mono_euroc \
    ./Vocabulary/superpoint_voc.dbow3 \
    ./Examples/Monocular/s100p_mono.yaml \
    ~/Sanexis/dataset/large_Fri_offline \
    ~/Sanexis/dataset/large_Fri_offline/timestamps.txt
```

> **注意**: 需要在有 X display 的环境运行（NoMachine 或本地终端）

## 已修复问题

### 初始化匹配器修复 (2026-04-17)

**问题**: 初始化阶段使用 `ORBmatcher` 而非 `SPmatcher`，导致匹配数从 800+ 下降到 27

**修复**: `src/Tracking.cc:2087`

```cpp
// 之前
ORBmatcher matcher(0.9,true);

// 之后
SPmatcher matcher(0.9,true);
```

**效果**: 初始化阶段现在使用 LightGlue 匹配，匹配数恢复到 800+ inliers

## 已知问题

### 1. PlaceRecognition 模型缺失

**现象**: 
```
Failed to load PlaceRecognition model: open file failed because of errno 2 on fopen: , file path: cosplace.pt
```

**影响**: 回环检测功能不可用

**解决方案**: 
- 下载 CosPlace 模型到项目根目录
- 或禁用回环检测

### 2. Pangolin X11 依赖

**现象**: 无 GUI 环境下崩溃
```
terminate called after throwing an instance of 'std::runtime_error'
  what():  Pangolin X11: Failed to open X display
```

**解决方案**: 通过 NoMachine 或本地终端运行

## 配置文件说明

`Examples/Monocular/s100p_mono.yaml`:

```yaml
# 特征提取参数
ORBextractor.nFeatures: 4000      # 特征点数量
ORBextractor.nLevels: 1           # 金字塔层数 (推荐 1 for SuperPoint)
ORBextractor.iniThFAST: 0.05      # SuperPoint 置信度阈值
ORBextractor.minThFAST: 0.02      # 最小置信度阈值

# SuperPoint FP16 推理
SuperPoint.useFP16: 1

# LightGlue 匹配器
LightGlue.model_path: "lightglue.pt"
LightGlue.useFP16: 0
```

## 文件结构

```
SP_SLAM3/
├── Examples/Monocular/
│   ├── mono_euroc.cc         # EuRoC 数据集运行入口
│   └── s100p_mono.yaml       # 相机配置文件
├── src/
│   ├── SPextractor.cc        # SuperPoint 特征提取
│   ├── SPmatcher.cc          # LightGlue 匹配器
│   └── Tracking.cc           # 跟踪模块
├── superpoint.pt             # SuperPoint 模型权重
├── lightglue.pt              # LightGlue 模型权重
├── Vocabulary/
│   └── superpoint_voc.dbow3  # 词袋文件
└── run_slam.sh               # 运行脚本
```

## 性能对比 (vismatch 测试)

| 测试场景 | SuperPoint+LightGlue | XFeat+LightGlue |
|---------|---------------------|-----------------|
| 连续帧匹配 | ~850 inliers | ~1400 inliers |
| Skip=50 | ~314 inliers | ~474 inliers |
| 推理速度 | ~51 ms | ~16 ms |

**结论**: XFeat 更快，SuperPoint 更鲁棒（困难场景 inlier rate 更高）

## 后续开发计划

1. **[High] 添加 Place Recognition 模型** - 启用回环检测
2. **[Medium] 支持无 GUI 运行** - 添加 headless 模式
3. **[Medium] 优化推理速度** - FP16、TensorRT
4. **[Low] 添加 IMU 支持** - 惯性导航

## 参考

- 原项目: https://github.com/fthbng77/SP_SLAM3
- SuperPoint: https://arxiv.org/abs/1712.07629
- LightGlue: https://arxiv.org/abs/2306.13643
- ORB-SLAM3: https://github.com/UZ-SLAMLab/ORB_SLAM3

## License

See LICENSE
