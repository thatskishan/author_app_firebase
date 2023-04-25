import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/author.png"),
          const SizedBox(
            height: 25,
          ),
          Text(
            "My Author",
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: Colors.white),
          )
        ],
      ),
    );
  }
}

/*

backgroundColor: const Color(0xff142841),
color: Color(0xff4560f6),
*/
