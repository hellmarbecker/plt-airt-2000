import sys
from confluent_kafka import Producer
from confluent_kafka.serialization import StringSerializer, SerializationContext, MessageField, Serializer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer

def main():

    # set up producer

    for line in sys.stdin:

        fields = line.rstrip('\n').split(',')

	# parse sbs1 values

        # put values in an object

	# serialize and send to kafka

if __name__ == "__main__":
    main()
