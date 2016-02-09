import 'dappsys/auth/auth.sol';

// Data store for dapphub registry: name, semver -> ipfs_hash
// Enforces semantic versioning and has simple-to-verify immutability (append-only).
// The notion of package "owners" and transferrability will be implemented
// by a business logic contract that will be granted ownership of this database.
// For now, it is simply manually curated.
contract DappHubDB is DSAuth {
    struct package_descriptor {
        // semver logic used in set
        uint8 latest_major_version;
        uint8 latest_minor_version;
        uint8 latest_patch_version;
        mapping( mapping( uint8 => mapping( uint8 => mapping( uint8 => bytes ) ) ) _hashes;
    }
    mapping( bytes32 => package_descriptor ) _packages;

    event PackageUpdate(bytes32 indexed name, uint8 major, uint8 minor, uint8 patch, bytes ipfs);

    // This function exists to extract a `bytes` type out of the contract
    // by an off-chain consumer (via `call`, not `sendTransaction`!).
    // There is no way to return `bytes` types to other contracts at this time.
    event IPFSHash(bytes _hash);
    function emitPackageHash(bytes32 name, uint8 major, uint8 minor, uint8 patch) {
        IPFSHash( _packages[name]._hashes[major][minor][patch] );
    }

    function setPackage(bytes32 name, uint8 major, uint8 minor, uint8 patch, bytes _hash)
             auth()
    {
        var package = _packages[name];
        if( major < package.latest_major_version ) {
            throw;
        } else if( major == package.latest_major_version ) {
            if( minor < package.latest_minor_version ) {
                throw;
            } else if( minor == package.latest_minor_version ) {
                if( patch <= package.latest_patch_version ) {
                    throw;
                }
            } else { // minor > latest.minor
                if( patch != 0 ) {
                    throw;
                }
            }
        } else { // major > latest.major
            if( minor != 0 ) {
                throw;
            }
            if( patch != 0 ) {
                throw;
            }
        }
        package._hashes[major][minor][path] = _hash;
        package.latest_major_version = major;
        package.latest_minor_version = minor;
        package.latest_patch_version = patch;
        _packages[name] = package;
        PackageUpdate(name, major, minor, patch, _hash );
    }
}