import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';

class UpcomingEvents extends StatelessWidget {
  const UpcomingEvents({super.key});

  @override
  Widget build(BuildContext context) {

    Widget events() {
      Widget location(String location) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: System.isMobile ? 10 : 20),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Theme
                  .of(context)
                  .colorScheme
                  .secondary,),
              SizedBox(width: System.isMobile ? 6 : 15,),
              Text(location, style: TextStyle(fontSize: System.isMobile ? 20 : 45,
                  color: Theme.of(context).colorScheme.onPrimary)),
            ],
          ),
        );
      }

      Widget eventPoster(){
        return Container(
          margin: EdgeInsets.symmetric(horizontal: System.isMobile ? 15 : 35),
          width: System.isMobile ? 150 : 360,
          height: System.isMobile ? 150 : 360,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.image,size: System.isMobile ? 50 : 100 ,color: Colors.grey ,),
        );
      }
      return Padding(
        padding: EdgeInsets.only(bottom: System.isMobile ? 35 : 65,top: System.isMobile ? 60 : 120 ),
        child: Column(
          mainAxisAlignment: .spaceBetween,
          crossAxisAlignment: .center,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: System.isMobile ? 12 : 24,
              runSpacing: System.isMobile ? 12 : 24,
              children: [
                eventPoster(),
                eventPoster(),
              ],
            ),
            Text("Expo Center",
              style: TextStyle(
                  fontSize: System.isMobile ? 20 : 45,
                  fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary
              ),),
            Row(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                location("Lahore"),
                location("Karachi"),
                location("Islamabad"),
              ],
            )
          ],
        ),
      );
    }

    return SizedBox(
      height: System.isMobile ? 320 : 790,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: System.isMobile ? 20 : 25,
            left: 0,
            right: 0,
            child: Container(
              height: System.isMobile ? 320 : 745,
              width: double.infinity,
              color: Theme
                  .of(context)
                  .colorScheme
                  .surfaceContainer,
              child: events(),
            ),
          ),
          Align(
              alignment: .topCenter,
              child: UiHelper.title(
                  context: context, title: "Upcoming Events")),
        ],
      ),
    );


  }
}
