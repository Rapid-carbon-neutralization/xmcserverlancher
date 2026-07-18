// 实例随机命名工具
// 提供中文风格随机实例名称池与随机命名函数。
// 创建实例（新建/导入）时会自动调用 [randomInstanceName] 生成默认名称。

import 'dart:math';

/// 中文风格随机实例名称池。
///
/// 用于实例创建时随机分配名称，便于用户快速区分不同实例。
const List<String> _instanceNamePool = [
  '静谧星辰',
  '流浪者号',
  '方块纪元',
  '星海彼岸',
  '暮色边境',
  '翡翠矿脉',
  '末日光年',
  '深空回响',
  '燃尽余烬',
  '破晓之翼',
  '苍穹之歌',
  '寂静岭港',
  '霓虹边缘',
  '银河信使',
  '时光沙漏',
  '极光要塞',
  '虚空回廊',
  '琥珀梦境',
  '朔月之冠',
  '星辰织梦',
];

/// 从名称池中随机返回一个实例名称。
///
/// 使用 [Random] 进行随机选择，每次调用都会重新生成随机源。
String randomInstanceName() {
  final random = Random();
  return _instanceNamePool[random.nextInt(_instanceNamePool.length)];
}
