import 'package:chatter_flutter/app.dart';
import 'package:chatter_flutter/helpers.dart';
import 'package:chatter_flutter/models/model.dart';
import 'package:chatter_flutter/screen/chat_screen.dart';
import 'package:chatter_flutter/themes.dart';
import 'package:chatter_flutter/widget/avatar.dart';
import 'package:chatter_flutter/widget/display_error_message.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../widget/unread_indicator.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final channelListController = ChannelListController();
    return ChannelListCore(
      channelListController: channelListController,
      filter: Filter.and(
        [
          Filter.equal('type', 'messaging'),
          Filter.in_('members', [
            StreamChatCore.of(context).currentUser!.id,
          ])
        ],
      ),
      emptyBuilder: (context) => const Center(
        child: Text(
          'So empty.\nGo and message someone',
          textAlign: TextAlign.center,
        ),
      ),
        errorBuilder: (context, error) => DisplayErrorMessage(
          error: error,
        ),
      loadingBuilder: (
          context,
      ) =>
      const Center(
        child: SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(),
        ),
      ),
      listBuilder: (context, channels) {
        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: _Stories(),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate(
                    (context, index){
                      return _MessageTitle(channel: channels[index],);
                    },
                    childCount: channels.length
                )
            )
          ],
        );
        },
    );
  }
}

class _MessageTitle extends StatelessWidget {
  const _MessageTitle({super.key,required this.channel});
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(ChatScreen.routeWithChannel(channel));
        },
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Avatar.medium(url: Helpers.getChannelImage(channel, context.currentUser!))
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        Helpers.getChannelName(channel, context.currentUser!),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          letterSpacing: 0.2,
                          wordSpacing: 1.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textFaded,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 20,
                      child: _buildLastMessage(),
                    )
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Column (
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 4,
                    ),
                    _buildLastMessageAt(),
                    const SizedBox(
                      height: 8,
                    ),
                    Center(child: UnreadIndicator(
                      channel: channel,

                    ))
                  ],
                )
            )
          ],
        )
    );
  }

  Widget _buildLastMessage() {
    return BetterStreamBuilder<int>(
      stream: channel.state!.unreadCountStream,
      initialData: channel.state?.unreadCount ?? 0,
      builder: (context, count) {
        return BetterStreamBuilder<Message>(
          stream: channel.state!.lastMessageStream,
          initialData: channel.state!.lastMessage,
          builder: (context, lastMessage) {
            return Text(
              lastMessage.text ?? '',
              overflow: TextOverflow.ellipsis,
              style: (count > 0)
                  ? const TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
              )
                  : const TextStyle(
                fontSize: 12,
                color: AppColors.textFaded,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLastMessageAt() {
    return BetterStreamBuilder<DateTime>(
      stream: channel.lastMessageAtStream,
      initialData: channel.lastMessageAt,
      builder: (context, data) {
        final lastMessageAt = data.toLocal();
        String stringDate;
        final now = DateTime.now();

        final startOfDay = DateTime(now.year, now.month, now.day);

        if (lastMessageAt.millisecondsSinceEpoch >=
            startOfDay.millisecondsSinceEpoch) {
          stringDate = Jiffy(lastMessageAt.toLocal()).jm;
        } else if (lastMessageAt.millisecondsSinceEpoch >=
            startOfDay
                .subtract(const Duration(days: 1))
                .millisecondsSinceEpoch) {
          stringDate = 'YESTERDAY';
        } else if (startOfDay.difference(lastMessageAt).inDays < 7) {
          stringDate = Jiffy(lastMessageAt.toLocal()).EEEE;
        } else {
          stringDate = Jiffy(lastMessageAt.toLocal()).yMd;
        }
        return Text(
          stringDate,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: -0.2,
            fontWeight: FontWeight.w600,
            color: AppColors.textFaded,
          ),
        );
      },
    );
  }

}

class _Stories extends StatelessWidget {
  const _Stories({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
        child: SizedBox(
            height: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'stories',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColors.textFaded
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      final faker = Faker();
                      return SizedBox(
                        width: 80,
                        child: _StoryCard(storyData:
                        StoryData(
                            name: faker.person.name(),
                            url: Helpers.randomPictureUrl()
                        ),
                      )
                      );
                    },
                  ),
                )
              ],
            )
        )
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({super.key, required this.storyData});

  final StoryData storyData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Avatar.medium(url: storyData.url),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              storyData.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ],
    );
  }
}