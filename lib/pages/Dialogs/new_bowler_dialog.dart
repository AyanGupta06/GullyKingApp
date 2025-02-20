import 'package:flutter/material.dart';
import 'package:gully_king/pages/New%20Game/Unranked%20Games/new_unranked_game_page.dart';

class NewBowlerDialog extends StatelessWidget {
  final List<Player> availableowlers;
  final Function(Player) onBowlerSelected;

  const NewBowlerDialog({
    Key? key,
    required this.availableowlers,
    required this.onBowlerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select a New Bowler"),
      content: DropdownButton<Player>(
        hint: const Text("Select Bowler"),
        items: availableowlers.map((Player player) {
          return DropdownMenuItem<Player>(
            value: player,
            child: Text(player.name),
          );
        }).toList(),
        onChanged: (Player? selectedPlayer) {
          if (selectedPlayer != null) {
            onBowlerSelected(selectedPlayer);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
