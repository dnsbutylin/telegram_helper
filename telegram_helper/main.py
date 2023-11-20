from faker import Faker

fake = Faker()


def main() -> None:
    while True:
        random_value = fake.random_int(min=100_000, max=999_999)
        print(random_value)
        if random_value == 100_001:
            break


if __name__ == "__main__":
    main()
