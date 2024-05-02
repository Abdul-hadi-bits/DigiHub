import 'package:digi_hub/Business_Logic/Settings_Logic/Profile/bloc/profile_bloc.dart';
import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart' as cache_images;

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<ProfileBloc>().add(ProfileLoadedEvent(loadLocal: false));
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.error)
          errorDialog(context, state.profileError);
      },
      child: Scaffold(
        appBar: MyAppBar(
          context: context,
          ttle: "Profile Setting",
          statusBarDark: true,
          fitTitle: true,
          italikTitle: true,
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                ProfileImageSection(),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      FirstNameTile(),
                      LastNameTile(),
                      LocationTile(),
                      settingSections(description: "ACCOUNT INFORMATION"),
                      EmailTile(),
                      PhoneTile(),
                      settingSections(description: "GLOBAL PREFERENCES"),
                      LanguageTile(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget settingSections({required String description}) {
    return ListTile(
      title: Text(
        description,
        style: TextStyle(
          fontSize: 17,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.only(left: 15),
      tileColor: Colors.grey.shade300,
    );
  }
}

class ProfileImageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      /* buildWhen: (previous, current) =>
          (current.profileUrl != previous.profileUrl), */
      builder: (context, state) {
        print(state.status);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            //color: Colors.blueGrey.shade200.withOpacity(0.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              state.profileUrl.isNotEmpty
                  ? Center(
                      child: cache_images.CachedNetworkImage(
                        imageUrl: state.profileUrl,
                        imageBuilder: (context, imageProvider) => Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                height:
                                    MediaQuery.of(context).size.width * 0.45,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(120),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    )),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Visibility(
                                visible: state.status ==
                                    ProfileStatus
                                        .updatingProfileImageInProgress,
                                child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: CupertinoActivityIndicator(
                                      animating: true,
                                      color: Colors.grey,
                                      radius: 15,
                                    )),
                              ),
                            ),
                          ],
                        ),
                        placeholder: (context, url) => Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: MediaQuery.of(context).size.width * 0.45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(120),
                            color: Colors.blueGrey.shade100,
                          ),
                          child: CupertinoActivityIndicator(
                              radius: 15, color: Colors.blue.shade900),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: MediaQuery.of(context).size.width * 0.45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(120),
                              color: Colors.grey,
                            ),
                            child: Center(
                              child: Icon(
                                CupertinoIcons.question_circle_fill,
                                color: Colors.red.shade400,
                                size: 35,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: MediaQuery.of(context).size.width * 0.45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                        color: Colors.blueGrey.shade100,
                      ),
                      /*   child: Center(
                        child: Text("No Image",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700)), */
                      //CupertinoActivityIndicator(radius: 15),)
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: InkWell(
                  child: Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(120),
                      color: Colors.amber.shade200,
                    ),
                    child: Center(
                      child: Text(
                        "Change",
                        style: TextStyle(
                            color: Colors.amber.shade700,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  splashColor: Colors.white,
                  onTap: () async {
                    // show image picker

                    context.read<ProfileBloc>().add(ProfileImageUpdateEvent());

                    //                  await setImage();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Divider(
                  thickness: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FirstNameTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("First Name",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Row(
            children: [
              BlocBuilder<ProfileBloc, ProfileState>(
                /*  buildWhen: (previous, current) =>
                    current.editName != previous.editName, */
                builder: (context, state) {
                  return state.status == ProfileStatus.editingNameState
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: TextField(
                            // controller: TextEditingController(text: state.name),
                            decoration: InputDecoration(
                                hintText: state.name,
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.bold),
                                errorText: state.nameError.isEmpty
                                    ? null
                                    : state.nameError),
                            onChanged: (text) {
                              context
                                  .read<ProfileBloc>()
                                  .add(ProfileNameEditEvent(name: text));
                            },
                          ),
                        )
                      : Text(
                          "${state.name}",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold),
                        );
                },
              ),
              BlocBuilder<ProfileBloc, ProfileState>(
                /* buildWhen: (previous, current) =>
                    current.isNameValid != previous.isNameValid ||
                    current.editName != previous.editName, */
                builder: (context, state) {
                  if (state.status == ProfileStatus.editingNameState &&
                      state.isNameValid &&
                      state.name.isNotEmpty) {
                    return IconButton(
                      icon: Icon(CupertinoIcons.check_mark),
                      onPressed: () async {
                        if (state.isNameValid) {
                          context.read<ProfileBloc>().add(
                              ProfileNameUpdateEvent(name: state.nameEdit));
                        }
                      },
                    );
                  }
                  if (state.status == ProfileStatus.editingNameState &&
                      !state.isNameValid) {
                    return IconButton(
                        onPressed: () async {
                          context
                              .read<ProfileBloc>()
                              .add(ProfileLoadedEvent(loadLocal: true));
                        },
                        icon: const Icon(CupertinoIcons.multiply));
                  }
                  if (state.status == ProfileStatus.updatingNameInProgress) {
                    return CircularProgressIndicator();
                  }
                  return IconButton(
                    onPressed: () async {
                      context
                          .read<ProfileBloc>()
                          .add(ProfileEnableEditingEvent(editingName: true));
                    },
                    icon: const Icon(CupertinoIcons.chevron_right_circle_fill),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LastNameTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Last Name",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Row(
            children: [
              BlocBuilder<ProfileBloc, ProfileState>(
                /*   buildWhen: (previous, current) =>
                    current.editLastName != previous.editLastName ||
                    current.status == ProfileStatus.loaded, */
                builder: (context, state) {
                  return (state.status == ProfileStatus.editingLastNameState)
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: state.lastName,
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold),
                              errorText: state.lastNameError.isEmpty
                                  ? null
                                  : state.lastNameError,
                            ),
                            onChanged: (text) {
                              context.read<ProfileBloc>().add(
                                  ProfileLastNameEditEvent(lastName: text));
                            },
                          ),
                        )
                      : Text("${state.lastName}",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold));
                },
              ),
              BlocBuilder<ProfileBloc, ProfileState>(
                /*  buildWhen: (previous, current) =>
                    current.isLastnameValid != previous.isLastnameValid ||
                    current.editLastName != previous.editLastName, */
                builder: (context, state) {
                  if (state.status == ProfileStatus.editingLastNameState &&
                      state.isLastnameValid &&
                      state.lastName.isNotEmpty) {
                    return IconButton(
                      icon: Icon(CupertinoIcons.check_mark),
                      onPressed: () async {
                        if (state.isLastnameValid) {
                          context.read<ProfileBloc>().add(
                              ProfileLastNameUpdateEvent(
                                  lastName: state.lastNameEdit));
                        }
                      },
                    );
                  }
                  if (state.status == ProfileStatus.editingLastNameState &&
                      !state.isLastnameValid) {
                    return IconButton(
                        onPressed: () async {
                          context
                              .read<ProfileBloc>()
                              .add(ProfileLoadedEvent(loadLocal: true));
                        },
                        icon: const Icon(CupertinoIcons.multiply));
                  } else if (state.status ==
                      ProfileStatus.updatingLastNameInProgress) {
                    return CircularProgressIndicator();
                  }
                  return IconButton(
                      onPressed: () async {
                        context.read<ProfileBloc>().add(
                            ProfileEnableEditingEvent(editingLastName: true));
                      },
                      icon:
                          const Icon(CupertinoIcons.chevron_right_circle_fill));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Location",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Row(
            children: [
              BlocBuilder<ProfileBloc, ProfileState>(
                  /* buildWhen: (previous, current) =>
                      current.editLocation != previous.editLocation, */
                  builder: (context, state) {
                return (state.status == ProfileStatus.editingLocationState)
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: state.location,
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold),
                            errorText: state.locationError.isEmpty
                                ? null
                                : state.locationError,
                          ),
                          onChanged: (text) {
                            context
                                .read<ProfileBloc>()
                                .add(ProfileLocationEditEvent(location: text));
                          },
                        ),
                      )
                    : Text("${state.location}",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold));
              }),
              BlocBuilder<ProfileBloc, ProfileState>(
                /*  buildWhen: (previous, current) =>
                    current.isLocationValid != previous.isLocationValid ||
                    current.editLocation != previous.editLocation, */
                builder: (context, state) {
                  if (state.status == ProfileStatus.editingLocationState &&
                      state.isLocationValid) {
                    return IconButton(
                      icon: Icon(CupertinoIcons.check_mark),
                      onPressed: () async {
                        if (state.isLocationValid) {
                          context.read<ProfileBloc>().add(
                              ProfileLocationUpdateEvent(
                                  locatoin: state.locationEdit));
                        }
                      },
                    );
                  }
                  if (state.status == ProfileStatus.editingLocationState &&
                      !state.isLocationValid) {
                    return IconButton(
                        onPressed: () async {
                          context
                              .read<ProfileBloc>()
                              .add(ProfileLoadedEvent(loadLocal: true));
                        },
                        icon: const Icon(CupertinoIcons.multiply));
                  }
                  if (state.status ==
                      ProfileStatus.updatingLocationInProgress) {
                    return CircularProgressIndicator();
                  }
                  return IconButton(
                      onPressed: () async {
                        print("clicked");
                        context.read<ProfileBloc>().add(
                            ProfileEnableEditingEvent(editingLocation: true));
                      },
                      icon:
                          const Icon(CupertinoIcons.chevron_right_circle_fill));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PhoneTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Phone",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Row(
            children: [
              BlocBuilder<ProfileBloc, ProfileState>(
                buildWhen: (previous, current) =>
                    current.phone != previous.phone,
                builder: (context, state) {
                  return Text(
                    "${state.phone}",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold),
                  );
                },
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/ChagenPhoneNumberPage",
                      /* PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: const ChangePhoneNumberPage()), */
                    ).whenComplete(
                      () {
                        context
                            .read<ProfileBloc>()
                            .add(ProfileLoadedEvent(loadLocal: false));
                      },
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.arrowCircleRight)),
            ],
          ),
        ],
      ),
    );
  }
}

class EmailTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Email",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                BlocBuilder<ProfileBloc, ProfileState>(
                  buildWhen: (previous, current) =>
                      current.email != previous.email,
                  builder: (context, state) {
                    return Text("${state.email}",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold));
                  },
                ),
                /*  IconButton(
                    onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.edit)), */
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const Text(
                "Language",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                "english",
                style: TextStyle(
                    color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ) //getUserInfo(userInfo: "language")),
            ],
          ),
          IconButton(
              onPressed: () {},
              icon: const FaIcon(FontAwesomeIcons.arrowCircleRight)),
        ],
      ),
    );
  }
}
