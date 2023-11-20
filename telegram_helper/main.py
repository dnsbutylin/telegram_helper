from faker import Faker

fake = Faker()


def main() -> None:
    while True:
        a = fake.random_int(min=100_000, max=999_999)
        print(a)
        if a == 100_001:
            break


if __name__ == "__main__":
    main()
