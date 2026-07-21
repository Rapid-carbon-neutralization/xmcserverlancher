// 实例列表主页
// 以圆角卡片形式展示所有服务器实例，点击进入详情页；提供「+ 新建实例」入口。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/server_instance.dart';
import '../state/app_state.dart';
import 'instance_detail_screen.dart';
import 'onboarding_screen.dart';

/// 实例列表主页。
///
/// 展示全部实例的圆角卡片（名称 + 状态标签），点击卡片进入
/// [InstanceDetailScreen]；右上角「+」按钮进入 [OnboardingScreen] 新建实例。
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XMCServerLauncher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新建实例',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const OnboardingScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final instances = state.instances;
          if (instances.isEmpty) {
            // 无实例时直接展示引导界面内容（新建/导入入口）。
            return const OnboardingScreen(embedded: true);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: instances.length,
            itemBuilder: (context, index) {
              final instance = instances[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InstanceCard(
                  instance: instance,
                  onTap: () {
                    state.selectInstance(instance.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => InstanceDetailScreen(
                          instanceId: instance.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// 实例圆角卡片。
///
/// 展示实例名称与状态标签（启动中/重启中/已关闭）。
class _InstanceCard extends StatelessWidget {
  const _InstanceCard({required this.instance, required this.onTap});

  final ServerInstance instance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.storage, size: 40, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instance.name,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    _StatusChip(status: instance.status),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

/// 实例状态标签。
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final InstanceStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      InstanceStatus.starting => Colors.orange,
      InstanceStatus.running => Colors.green,
      InstanceStatus.restarting => Colors.amber,
      InstanceStatus.stopped => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
