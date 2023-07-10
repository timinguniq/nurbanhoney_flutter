import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawerProfilePreview extends StatelessWidget {
  const DrawerProfilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      final authenticationProvider = ref.watch(authenticationServiceProvider);

      return authenticationProvider == AuthenticationStatus.authenticated
        ? SizedBox()
        : SizedBox(
          width: 260,
          height: 50,
          child: Row(
            children: [
              Text(
                '로그인 후\n이용해 주세요.',
                overflow: TextOverflow.ellipsis,
              ),
              Expanded(
                child: SizedBox(),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                child: Text(
                  '로그인',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        );
    });
  }
}
