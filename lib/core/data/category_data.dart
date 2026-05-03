import 'package:flutter/material.dart';

class SubCategory {
  final String name;
  final List<String>? models;

  const SubCategory({
    required this.name,
    this.models,
  });
}

class AuctionCategory {
  final String name;
  final IconData icon;
  final List<SubCategory>? subCategories;

  const AuctionCategory({
    required this.name,
    required this.icon,
    this.subCategories,
  });
}

class CategoryData {
  static const List<AuctionCategory> categories = [
    AuctionCategory(
      name: 'Mobiles',
      icon: Icons.smartphone,
      subCategories: [
        SubCategory(name: 'Mobile Phones', models: ['Apple', 'Samsung', 'Google', 'Xiaomi', 'Oppo', 'Vivo', 'Realme', 'Infinix', 'Tecno', 'Other']),
        SubCategory(name: 'Accessories'),
        SubCategory(name: 'Smart Watches'),
        SubCategory(name: 'Tablets', models: ['Apple', 'Samsung', 'Lenovo', 'Huawei', 'Other']),
        SubCategory(name: 'Other'),
      ],
    ),
    AuctionCategory(
      name: 'Vehicles',
      icon: Icons.directions_car,
      subCategories: [
        SubCategory(name: 'Cars', models: ['Toyota', 'Honda', 'Suzuki', 'Kia', 'Hyundai', 'Changan', 'MG', 'Proton', 'Audi', 'Mercedes-Benz', 'BMW', 'Other']),
        SubCategory(name: 'Cars on Installments'),
        SubCategory(name: 'Cars Accessories'),
        SubCategory(name: 'Spare Parts'),
        SubCategory(name: 'Buses, Vans & Trucks'),
        SubCategory(name: 'Rickshaw & Chingchi'),
        SubCategory(name: 'Other Vehicles'),
        SubCategory(name: 'Boats'),
        SubCategory(name: 'Tractors & Agricultural'),
      ],
    ),
    AuctionCategory(
      name: 'Property for Sale',
      icon: Icons.apartment,
      subCategories: [
        SubCategory(name: 'Land & Plots'),
        SubCategory(name: 'Houses'),
        SubCategory(name: 'Apartments & Flats'),
        SubCategory(name: 'Shops - Offices - Commercial Space'),
        SubCategory(name: 'Portions & Floors'),
      ],
    ),
    AuctionCategory(
      name: 'Property for Rent',
      icon: Icons.vpn_key,
      subCategories: [
        SubCategory(name: 'Houses'),
        SubCategory(name: 'Apartments & Flats'),
        SubCategory(name: 'Portions & Floors'),
        SubCategory(name: 'Shops - Offices - Commercial Space'),
        SubCategory(name: 'Rooms'),
        SubCategory(name: 'Roommates & Paying Guests'),
        SubCategory(name: 'Vacation Rentals - Guest Houses'),
        SubCategory(name: 'Land & Plots'),
      ],
    ),
    AuctionCategory(
      name: 'Electronics & Home Appliances',
      icon: Icons.kitchen,
      subCategories: [
        SubCategory(name: 'Computers & Accessories', models: ['Apple', 'Dell', 'HP', 'Lenovo', 'Asus', 'Acer', 'MSI', 'Other']),
        SubCategory(name: 'Televisions & Accessories', models: ['Samsung', 'LG', 'Sony', 'TCL', 'Hisense', 'EcoStar', 'Orient', 'Other']),
        SubCategory(name: 'Home Appliances'),
        SubCategory(name: 'Generators, UPS & Power Solutions'),
        SubCategory(name: 'Other Home Appliances'),
        SubCategory(name: 'Games & Entertainment', models: ['PlayStation', 'Xbox', 'Nintendo', 'Other']),
        SubCategory(name: 'Cameras & Accessories', models: ['Canon', 'Nikon', 'Sony', 'Fujifilm', 'Panasonic', 'Other']),
        SubCategory(name: 'AC & Coolers', models: ['Gree', 'Haier', 'Dawlance', 'Pel', 'Orient', 'Kenwood', 'Other']),
        SubCategory(name: 'Fridges & Freezers', models: ['Dawlance', 'Haier', 'Pel', 'Orient', 'Samsung', 'Other']),
        SubCategory(name: 'Washing Machines & Dryers'),
      ],
    ),
    AuctionCategory(
      name: 'Bikes',
      icon: Icons.two_wheeler,
      subCategories: [
        SubCategory(name: 'Motorcycles', models: ['Honda', 'Yamaha', 'Suzuki', 'United', 'Road Prince', 'Hi-Speed', 'Super Power', 'Other']),
        SubCategory(name: 'Spare Parts'),
        SubCategory(name: 'Bicycles'),
        SubCategory(name: 'ATV & Quads'),
        SubCategory(name: 'Scooters'),
        SubCategory(name: 'Other'),
      ],
    ),
    AuctionCategory(
      name: 'Business, Industrial & Agriculture',
      icon: Icons.agriculture,
      subCategories: [
        SubCategory(name: 'Business for Sale'),
        SubCategory(name: 'Food & Restaurants'),
        SubCategory(name: 'Trade & Industrial'),
        SubCategory(name: 'Construction & Heavy Machinery'),
        SubCategory(name: 'Agriculture'),
        SubCategory(name: 'Other Business & Industry'),
        SubCategory(name: 'Medical & Pharma'),
      ],
    ),
    AuctionCategory(
      name: 'Services',
      icon: Icons.handyman,
      subCategories: [
        SubCategory(name: 'Education & Classes'),
        SubCategory(name: 'Travel & Visa'),
        SubCategory(name: 'Car Rental'),
        SubCategory(name: 'Drivers & Taxi'),
        SubCategory(name: 'Web Development'),
        SubCategory(name: 'Other Services'),
        SubCategory(name: 'Electronics & Computer Repair'),
        SubCategory(name: 'Event Services'),
        SubCategory(name: 'Health & Beauty'),
        SubCategory(name: 'Maids & Domestic Help'),
        SubCategory(name: 'Movers & Packers'),
        SubCategory(name: 'Home & Office Repair'),
        SubCategory(name: 'Catering & Restaurant'),
        SubCategory(name: 'Farm & Fresh Food'),
      ],
    ),
    AuctionCategory(
      name: 'Jobs',
      icon: Icons.work,
      subCategories: [
        SubCategory(name: 'Online'),
        SubCategory(name: 'Marketing'),
        SubCategory(name: 'Advertising & PR'),
        SubCategory(name: 'Education'),
        SubCategory(name: 'Customer Service'),
        SubCategory(name: 'Sales'),
        SubCategory(name: 'IT & Networking'),
        SubCategory(name: 'Hotels & Tourism'),
        SubCategory(name: 'Clerical & Administration'),
        SubCategory(name: 'Human Resources'),
        SubCategory(name: 'Accounting & Finance'),
        SubCategory(name: 'Manufacturing'),
        SubCategory(name: 'Medical'),
        SubCategory(name: 'Domestic Staff'),
        SubCategory(name: 'Part - Time'),
        SubCategory(name: 'Other Jobs'),
      ],
    ),
    AuctionCategory(
      name: 'Animals',
      icon: Icons.pets,
      subCategories: [
        SubCategory(name: 'Fish & Aquariums'),
        SubCategory(name: 'Birds'),
        SubCategory(name: 'Hens & Aseel'),
        SubCategory(name: 'Cats'),
        SubCategory(name: 'Dogs'),
        SubCategory(name: 'Livestock'),
        SubCategory(name: 'Horses'),
        SubCategory(name: 'Pet Food & Accessories'),
        SubCategory(name: 'Other Animals'),
      ],
    ),
    AuctionCategory(
      name: 'Furniture & Home Decor',
      icon: Icons.chair,
      subCategories: [
        SubCategory(name: 'Sofa & Chairs'),
        SubCategory(name: 'Beds & Wardrobes'),
        SubCategory(name: 'Home Decoration'),
        SubCategory(name: 'Tables & Dining'),
        SubCategory(name: 'Garden & Outdoor'),
        SubCategory(name: 'Painting & Finishing'),
        SubCategory(name: 'Rugs & Carpets'),
        SubCategory(name: 'Curtains & Blinds'),
        SubCategory(name: 'Office Furniture'),
        SubCategory(name: 'Other Household Items'),
      ],
    ),
    AuctionCategory(
      name: 'Fashion & Beauty',
      icon: Icons.checkroom,
      subCategories: [
        SubCategory(name: 'Accessories'),
        SubCategory(name: 'Clothes'),
        SubCategory(name: 'Footwear'),
        SubCategory(name: 'Jewellery'),
        SubCategory(name: 'Make Up'),
        SubCategory(name: 'Skin & Hair'),
        SubCategory(name: 'Watches'),
        SubCategory(name: 'Wedding'),
        SubCategory(name: 'Lawn & Pret'),
        SubCategory(name: 'Couture'),
        SubCategory(name: 'Other Fashion'),
      ],
    ),
    AuctionCategory(
      name: 'Books',
      icon: Icons.menu_book,
      subCategories: [
        SubCategory(name: 'Books'),
        SubCategory(name: 'Magazines'),
        SubCategory(name: 'Other'),
      ],
    ),
    AuctionCategory(
      name: 'Sports & Hobbies',
      icon: Icons.sports_tennis,
      subCategories: [
        SubCategory(name: 'Sports Equipment'),
        SubCategory(name: 'Gym & Fitness'),
        SubCategory(name: 'Musical Instruments'),
        SubCategory(name: 'Other Hobbies'),
      ],
    ),
    AuctionCategory(
      name: 'Kids',
      icon: Icons.child_care,
      subCategories: [
        SubCategory(name: 'Kids Furniture'),
        SubCategory(name: 'Toys'),
        SubCategory(name: 'Prams & Walkers'),
        SubCategory(name: 'Swings & Slides'),
        SubCategory(name: 'Kids Accessories'),
        SubCategory(name: 'Kids Clothing'),
        SubCategory(name: 'Bath & Diapers'),
      ],
    ),
    AuctionCategory(
      name: 'Other',
      icon: Icons.more_horiz,
      subCategories: [
        SubCategory(name: 'Miscellaneous'),
      ],
    ),
  ];
}
