import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/monthly_medal.model.dart';

class MedalListWidget extends StatelessWidget {
  final List<Medal> medals;

  const MedalListWidget({
    super.key,
    required this.medals,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: medals.length,
      itemBuilder: (context, index) {
        final medal = medals[index];
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: PaddingSizes.large,
            vertical: PaddingSizes.small,
          ),
          decoration: BoxDecoration(
            color: CoreColors.foregroundColor,
            borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(PaddingSizes.medium),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: CoreColors.backgroundColor,
                borderRadius: BorderRadius.circular(BorderRadiusSizes.small),
              ),
              child: Center(
                child: FaIcon(
                  medal.icon,
                  color: medal.color,
                  size: IconSizes.medium,
                ),
              ),
            ),
            title: Text(
              medal.title,
              style: const TextStyle(
                fontSize: FontSizes.medium,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              medal.description,
              style: const TextStyle(
                fontSize: FontSizes.small,
              ),
            ),
          ),
        );
      },
    );
  }
} 
