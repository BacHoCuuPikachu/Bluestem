# Bluestem

Personal storage system.

## Development

To run the web application locally with emulated storage, install `Azurite`:

```ps
npm install -g azurite
```

Run `Azurite` in a separate terminal:

```ps
azurite --silent --location c:\azurite --debug c:\azurite\debug.log
```

Run the web application:

```ps
npm run dev
```

You can also explore the content of the emulated storage with [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/#overview).
