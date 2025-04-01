import 'package:flutter/material.dart';
import 'package:gully_king/pages/New%20Game/Ranked%20Games/coin_flip_page.dart';

class NewRankedInningsSetupDialog extends StatefulWidget {
  final Function(Player, Player) onBatsmenAndBowlerSelected;
  final List<Player> availableBatsmen;
  final List<Player> availableBowlers;

  const NewRankedInningsSetupDialog({
    super.key,
    required this.onBatsmenAndBowlerSelected,
    required this.availableBatsmen,
    required this.availableBowlers,
  });

  @override
  _NNewRankedInningsSetupDialogState createState() => _NNewRankedInningsSetupDialogState();
}

class _NNewRankedInningsSetupDialogState extends State<NewRankedInningsSetupDialog> {
  Player? newStrike;
  Player? newNonStrike;
  //Player? newBowler;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Up Second Innings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<Player>(
            hint: const Text('Select Strike Batsman'),
            value: newStrike,
            onChanged: (Player? player) {
              setState(() {
                newStrike = player;
              });
            },
            items: widget.availableBatsmen.map((Player batsman) {
              return DropdownMenuItem<Player>(
                value: batsman,
                child: Text(batsman.username),
              );
            }).toList(),
          ),
          DropdownButton<Player>(
            hint: const Text('Select Non-Strike Batsman'),
            value: newNonStrike,
            onChanged: (Player? player) {
              setState(() {
                newNonStrike = player;
              });
            },
            items: widget.availableBatsmen.map((Player batsman) {
              return DropdownMenuItem<Player>(
                value: batsman,
                child: Text(batsman.username),
              );
            }).toList(),
          ),
          // DropdownButton<Player>(
          //   hint: const Text('Select Bowler'),
          //   value: newBowler,
          //   onChanged: (Player? player) {
          //     setState(() {
          //       newBowler = player;
          //     });
          //   },
          //   items: widget.availableBowlers.map((Player bowler) {
          //     return DropdownMenuItem<Player>(
          //       value: bowler,
          //       child: Text(bowler.name),
          //     );
          //   }).toList(),
          // ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (newStrike != null && newNonStrike != null &&  newStrike != newNonStrike) {
              widget.onBatsmenAndBowlerSelected(newStrike!, newNonStrike!);
              Navigator.of(context).pop();
            } 
            else if(newStrike == newNonStrike) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Select different players for both batsmen positions.')),
              );
            }else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select all players.')),
              );
            }
             
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}